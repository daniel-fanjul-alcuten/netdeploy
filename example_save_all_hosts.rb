#!/usr/bin/env jruby

require './lib/mkworkdir.rb'
require './lib/execute_threads.rb'
require './lib/save_host.rb'

operations = []
projects.each { |project|
	hosts.each { |host|
		operations << { :project => project, :host => host, :path => host_path(project, host) }
	}
}

mkworkdirs(num_threads) { |dirs|
	execute_threads(dirs, operations) { |dir, operation, first_time|

		git_clone dir if first_time

		project = operation[:project]
		host = operation[:host]
		path = operation[:path]
		save_host project, host, path, dir, first_time
	}
}

puts 'DONE'
