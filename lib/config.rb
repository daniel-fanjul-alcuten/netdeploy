#!/usr/bin/env ruby1.9.1

def project_ref project
	"refs/projects/#{project}"
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
