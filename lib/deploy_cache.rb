#!/usr/bin/env jruby

require 'thread'
require 'fileutils'
require './lib/execute_git.rb'

class DeployCache
	def initialize
		@work_dirs = {}
		@work_dirs_mutex = Mutex.new
	end

	def work_dir_checkout hash
		while true
			dir, mutex = @work_dirs_mutex.synchronize {
				dir_or_mutex = @work_dirs[hash]
				if dir_or_mutex.kind_of? String
					dir = dir_or_mutex
					[dir, nil]
				elsif dir_or_mutex.nil?
					mutex = @work_dirs[hash] = Mutex.new
					[nil, mutex.lock]
				else
					mutex = dir_or_mutex
					[mutex, mutex]
				end
			}
			if mutex.nil?
				return dir
			elsif dir.nil?
				dir = "work-hash-#{hash}.tmp"
				begin
					git_clone dir
					git_checkout dir, dir, hash
					@work_dirs_mutex.synchronize {
						@work_dirs[hash] = dir
					}
					return dir
				rescue
					begin
						FileUtils.remove_entry_secure dir
					ensure
						@work_dirs_mutex.synchronize {
							@work_dirs[hash] = nil
						}
					end
				ensure
					mutex.unlock
				end
			else
				mutex.synchronize { }
			end
		end
	end

	def remove_work_dirs
		@work_dirs.values.each { |dir|
			if dir.kind_of? String
				FileUtils.remove_entry_secure dir
			end
		}
	end
end
