#!/usr/bin/env jruby

require './lib/mkworkdir.rb'
require './lib/save_project.rb'

raise "usage: #{$0} <project name> <project path>" if ARGV.count != 2
project = ARGV[0]
path = ARGV[1]

mkworkdir { |dir|
	git_clone dir

	save_project project, path, dir
}

puts 'DONE'
