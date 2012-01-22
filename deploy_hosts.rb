#!/usr/bin/env jruby

require './lib/deploy_cache.rb'
require './lib/deploy_host.rb'

raise "usage: #{$0} <project name> <remote path> <host name>+" if ARGV.count < 3
project = ARGV[0]
path = ARGV[1]
hosts = ARGV[2..-1]

deploy_cache = DeployCache.new
begin
	hosts.each { |host|
		deploy_host project, host, path, deploy_cache
	}
ensure
	deploy_cache.remove_work_dirs
end

puts 'DONE'
