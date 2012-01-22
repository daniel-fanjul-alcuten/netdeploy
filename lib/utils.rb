#!/usr/bin/env ruby1.9.1

def mkworkdir
	require 'tmpdir'
	Dir.mktmpdir(['work-', '.tmp'], '.') { |dir|
		yield dir
	}
end

def execute_lines command, options = {}
	command_prefix = options[:command_prefix]
	input = options[:input]
	print_output = options[:print_output].nil? or options[:print_output]
	check_status = options[:check_status].nil? or options[:check_status]

	puts "-> #{command_prefix}#{command}"
	lines = []
	IO.popen(command, (input ? 'r+' : 'r'), 2 => 1) { |io|
		if input
			t = Thread.new {
				io.puts input
				io.close_write
			}
		end
		if print_output
			io.each_line { |line|
				lines << line
				puts "#{line}"
			}
		else
			lines = io.readlines
			puts "[...] (#{lines.count} lines)"
		end
	}
	raise "command terminated with exit status #{$?.to_i}" if check_status and $?.to_i != 0
	puts
	lines
end

def execute_bool command, options = {}
	execute_lines command, options.merge(:check_status => false)
	$?.to_i == 0
end

def execute_first_line options = {}
	lines = execute_lines options
	lines[0].chomp
end

def next_work_id
	Thread.exclusive {
		$last_work_id = ($last_work_id ? $last_work_id + 1 : 1)
	}
end

def git_dir dir
	"git --git-dir '#{dir}/.git'"
end

def git_dir_tree dir, tree
	"#{git_dir dir} --work-tree '#{tree}'"
end
