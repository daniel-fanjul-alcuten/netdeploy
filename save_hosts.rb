#!/usr/bin/env jruby

require './lib/mkworkdir.rb'
require './lib/save_host.rb'

raise "usage: #{$0} <project name> <remote path> <host name>+" if ARGV.count < 3
project = ARGV[0]
path = ARGV[1]
hosts = ARGV[2..-1]

mkworkdir { |dir|
	git_clone dir

	first_time = true
	hosts.each { |host|
		save_host project, host, path, dir, first_time
		first_time = false
	}
}

puts 'DONE'
