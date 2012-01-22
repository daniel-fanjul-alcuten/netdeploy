#!/usr/bin/env jruby

require './lib/mkworkdir.rb'
require './lib/execute_git.rb'

def deploy_host project, host, path, deploy_cache

	project_hash = git_rev_parse_project project
	raise "project #{project} not found" unless project_hash

	host_hash = git_rev_parse_host project, host
	if host_hash then
		mkworkdir { |dir|
			file = dir + '/diff'
			git_diff host_hash, project_hash, file
			if File.size(file) > 0
				ssh_git_apply host, path, file
				commit = git_commit_tree_host project_hash, "#{host}:#{path} => #{project}", save_host_history ? host_hash : nil
				git_update_host_ref project, host, commit
			end
		}
	else
		dir = deploy_cache.work_dir_checkout project_hash
		execute_rsync dir, "#{host}:#{path}"
		commit = git_commit_tree_host project_hash, "#{host}:#{path} => #{project}"
		git_update_host_ref project, host, commit
	end
end
