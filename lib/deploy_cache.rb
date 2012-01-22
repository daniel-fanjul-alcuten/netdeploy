#!/usr/bin/env ruby1.9.1

require './lib/config.rb'

class DeployCache
	def initialize
		@work_dirs = {}
	end

	def work_dir_checkout hash
		Thread.exclusive {
			if not @work_dirs[hash]
				dir = "work-hash-#{hash}.tmp"
				execute_lines "git clone -n -s . '#{dir}'"
				execute_lines "#{git_dir_tree dir, dir} checkout --detach #{hash}"
				@work_dirs[hash] = dir
			end
		}
		@work_dirs[hash]
	end

	def remove_work_dirs
		require 'fileutils'
		@work_dirs.values.each { |dir|
			FileUtils.remove_entry_secure dir
		}
	end
end
