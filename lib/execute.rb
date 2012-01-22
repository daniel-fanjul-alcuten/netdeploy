#!/usr/bin/env jruby

require 'thread'

def execute_lines command, options = {}
	command_prefix = options[:command_prefix]
	input = options[:input]
	print_output = options[:print_output].nil? or options[:print_output]
	check_status = options[:check_status].nil? or options[:check_status]

	puts "-> #{command_prefix}#{command}"
	lines = []
	IO.popen("#{command} 2>&1", input ? 'r+' : 'r') { |io|
		if input
			Thread.new {
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
	raise "command \"#{command}\" terminated with exit status #{$?.to_i >> 8}" if check_status and not $?.success?
	puts
	lines
end

def execute_first_line command, options = {}
	lines = execute_lines command, options
	lines.count > 0 ? lines[0].chomp : nil
end

def execute_first_line_bool command, options = {}
	line = execute_first_line command, options.merge(:check_status => false)
	$?.success? ? line : false
end

def execute_rsync source, target
	execute_lines "rsync -avh --stats --delete --exclude=.git '#{source}/' '#{target}'"
end
