#!/usr/bin/env ruby1.9.1

require './lib/save_project.rb'
require './lib/deploy_cache.rb'
require './lib/deploy_host.rb'

projects = ['foo', 'bar']

mkworkdir { |dir|
	execute_lines "git clone -n -s . '#{dir}'"

	projects.each { |project|
		save_project project, 'build/' + project, dir
	}
}

deploy_cache = DeployCache.new
begin
	projects.each { |project|
		deploy_host project, 'localhost', '/tmp/deploy1/' + project, deploy_cache
		deploy_host project, `hostname`.chomp, '/tmp/deploy2/' + project, deploy_cache
	}
ensure
	deploy_cache.remove_work_dirs
end

puts 'DONE'
