#!/usr/bin/env jruby

def projects
	(1..99).map { |i| 'foo' + i.to_s }
end

def project_path project
	'build'
end

def project_ref project
	"refs/projects/#{project}"
end

def hosts
	['localhost', `hostname`.chomp]
end

def host_path project, host
	"/tmp/deploy/#{project}/#{host}"
end

def host_ref project, host
	"refs/hosts/#{project}/#{host}"
end

def save_project_history
	true
end

def save_host_history
	true
end

def num_threads
	6
end
