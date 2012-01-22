#!/usr/bin/env ruby1.9.1

require './lib/config.rb'
require './lib/utils.rb'

def deploy_host project, host, path, deploy_cache
	project_ref = project_ref project
	host_ref = host_ref project, host

	project_hash = execute_first_line "git rev-parse #{project_ref}"

	if execute_bool "git show-ref #{host_ref}" then
		host_hash = execute_first_line "git rev-parse #{host_ref}"
		diff = execute_lines "git diff --binary #{host_hash} #{project_hash}", :print_output => false
		if diff.count > 0
			execute_lines "ssh #{host} \"cd '#{path}' && git apply -v\"", :command_prefix => 'echo <<diff>> | ', :input => diff
			parent_option = save_host_history ? " -p #{host_ref}" : nil
			commit = execute_first_line "echo '#{host}:#{path} => #{project}' | git commit-tree #{project_hash}:#{parent_option}"
			execute_lines "git update-ref #{host_ref} #{commit}"
		end
	else
		dir = deploy_cache.work_dir_checkout project_hash
		execute_lines "rsync -avh --delete --exclude=.git '#{dir}/' '#{host}:#{path}'"
		commit = execute_first_line "echo '#{host}:#{path} => #{project}' | git commit-tree #{project_hash}:"
		execute_lines "git update-ref #{host_ref} #{commit}"
	end
end
