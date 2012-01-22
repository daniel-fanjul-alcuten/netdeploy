#!/usr/bin/env ruby1.9.1

require './lib/config.rb'
require './lib/utils.rb'

def save_project project, path, dir
	project_ref = project_ref project
	git_dir = git_dir dir

	if save_project_history and execute_bool "git show-ref #{project_ref}" then
		execute_lines "#{git_dir} fetch origin #{project_ref}"
		execute_lines "#{git_dir} update-ref --no-deref HEAD FETCH_HEAD"
	else
		execute_lines "#{git_dir} symbolic-ref HEAD refs/heads/work#{next_work_id}"
	end
	execute_lines "#{git_dir_tree dir, path} add -A -v"
	execute_lines "#{git_dir} commit --allow-empty -m '#{path} => #{project}'"
	execute_lines "#{git_dir} push -f origin HEAD:#{project_ref}"
end
