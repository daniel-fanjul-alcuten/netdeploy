#!/usr/bin/env jruby

require 'thread'
require './lib/config.rb'
require './lib/execute.rb'

def git_dir dir
	"git --git-dir '#{dir}/.git'"
end

def git_dir_tree dir, tree
	"#{git_dir dir} --work-tree '#{tree}'"
end

def git_clone dir
	execute_lines "git clone -n -s . '#{dir}'"
end

def git_rev_parse_project project
	execute_first_line_bool "git rev-parse #{project_ref project}"
end

def git_rev_parse_host project, host
	execute_first_line_bool "git rev-parse #{host_ref project, host}"
end

def git_checkout dir, tree, hash
	execute_lines "#{git_dir_tree dir, tree} checkout --detach #{hash}"
end

def git_update_ref_HEAD dir, hash
	execute_lines "#{git_dir dir} update-ref --no-deref HEAD #{hash}"
end

$last_work_id_mutex = Mutex.new
def git_symbolic_ref_HEAD dir
	$last_work_id_mutex.synchronize {
		$last_work_id = ($last_work_id ? $last_work_id + 1 : 1)
	}
	execute_lines "#{git_dir dir} symbolic-ref HEAD refs/heads/work#{$last_work_id}"
end

def git_update_host_ref project, host, hash
	execute_lines "git update-ref #{host_ref project, host} #{hash}"
end

def git_add dir, tree
	execute_lines "#{git_dir_tree dir, tree} add -A -v"
end

def git_commit dir, message
	execute_lines "#{git_dir dir} commit -q --allow-empty -m '#{message}'"
end

def git_commit_tree_host ref, message, parent = nil
	parent_option = parent ? " -p #{parent}" : nil
	execute_first_line "echo '#{message}' | git commit-tree #{ref}:#{parent_option}"
end

def git_push_project dir, project
	execute_lines "#{git_dir dir} push -f origin HEAD:#{project_ref project}"
end

def git_push_host dir, project, host
	execute_lines "#{git_dir dir} push -f origin HEAD:#{host_ref project, host}"
end

def git_diff source, target, file
	execute_lines "git diff --binary #{source} #{target} > '#{file}'"
end

def ssh_git_apply host, dir, file
	execute_lines "ssh #{host} \"cd '#{dir}' && git apply -v\" < '#{file}'"
end
