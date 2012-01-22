#!/usr/bin/env ruby1.9.1

require './lib/config.rb'
require './lib/utils.rb'

def save_host project, host, path, dir, first_time
	host_ref = host_ref project, host
	git_dir = git_dir dir
	git_dir_tree = git_dir_tree dir, dir

	if (save_host_history or first_time) and execute_bool "git show-ref #{host_ref}" then
		execute_lines "#{git_dir} fetch origin #{host_ref}"
		if first_time then
			execute_lines "#{git_dir_tree} checkout --detach FETCH_HEAD"
		end
		if not save_host_history
			execute_lines "#{git_dir} symbolic-ref HEAD refs/heads/work#{next_work_id}"
		elsif not first_time
			execute_lines "#{git_dir} update-ref --no-deref HEAD FETCH_HEAD"
		end
	else
		execute_lines "#{git_dir} symbolic-ref HEAD refs/heads/work#{next_work_id}"
	end

	execute_lines "rsync -avh --delete --exclude=.git '#{host}:#{path}/' '#{dir}'"
	execute_lines "#{git_dir_tree} add -A -v"
	execute_lines "#{git_dir} commit --allow-empty -m '#{host}:#{path} => #{project}'"
	execute_lines "#{git_dir} push -f origin HEAD:#{host_ref}"
end
