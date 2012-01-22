#!/usr/bin/env jruby

require './lib/execute_git.rb'

def save_host project, host, path, dir, first_time

	head_updated = false
	if save_host_history or first_time
		host_hash = git_rev_parse_host project, host
		if host_hash then
			if first_time then
				git_checkout dir, dir, host_hash
				head_updated = true if save_host_history
			elsif save_host_history
				git_update_ref_HEAD dir, host_hash
				head_updated = true
			end
		end
	end
	if not head_updated then
		git_symbolic_ref_HEAD dir
	end

	execute_rsync "#{host}:#{path}", dir
	git_add dir, path
	git_commit dir, "#{host}:#{path} => #{project}"
	git_push_host dir, project, host
end
