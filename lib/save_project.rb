#!/usr/bin/env jruby

require './lib/execute_git.rb'

def save_project project, path, dir

	head_updated = false
	if save_project_history then
		project_hash = git_rev_parse_project project
		if project_hash then
			git_update_ref_HEAD dir, project_hash
			head_updated = true
		end
	end
	if not head_updated then
		git_symbolic_ref_HEAD dir
	end

	git_add dir, path
	git_commit dir, "#{path} => #{project}"
	git_push_project dir, project
end
