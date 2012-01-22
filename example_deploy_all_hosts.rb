#!/usr/bin/env jruby

require './lib/mkworkdir.rb'
require './lib/execute_threads.rb'
require './lib/save_project.rb'
require './lib/deploy_cache.rb'
require './lib/deploy_host.rb'

operations = []
projects.each { |project|
	operations << { :project => project, :path => project_path(project) }
}

mkworkdirs(num_threads) { |dirs|
	execute_threads(dirs, operations) { |dir, operation, first_time|

		git_clone dir if first_time

		project = operation[:project]
		path = operation[:path]
		save_project project, path, dir
	}
}

operations = []
projects.each { |project|
	hosts.each { |host|
		operations << { :project => project, :host => host, :remote_path => host_path(project, host) }
	}
}

deploy_cache = DeployCache.new
begin
	execute_threads(1..num_threads, operations) { |dir, operation, first_time|
		project = operation[:project]
		host = operation[:host]
		remote_path = operation[:remote_path]
		deploy_host project, host, remote_path, deploy_cache
	}
ensure
	deploy_cache.remove_work_dirs
end

puts 'DONE'
