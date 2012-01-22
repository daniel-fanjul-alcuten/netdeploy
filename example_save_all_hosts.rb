#!/usr/bin/env ruby1.9.1

require './lib/save_host.rb'

projects = ['foo', 'bar']

mkworkdir { |dir|
	execute_lines "git clone -n -s . '#{dir}'"

	first_time = true
	projects.each { |project|
		save_host project, 'localhost', '/tmp/deploy1/' + project, dir, first_time
		first_time = false
		save_host project, `hostname`.chomp, '/tmp/deploy2/' + project, dir, first_time
	}
}

puts 'DONE'
