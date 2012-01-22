#!/usr/bin/env ruby1.9.1

require './lib/save_project.rb'

raise "usage: #{$0} <project name> <project path>" if ARGV.count != 2
project = ARGV[0]
path = ARGV[1]

mkworkdir { |dir|
	execute_lines "git clone -n -s . '#{dir}'"

	save_project project, path, dir
}

puts 'DONE'
