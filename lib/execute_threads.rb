#!/usr/bin/env jruby

require 'thread'

def execute_threads thread_info, operations

	operations_mutex = Mutex.new

	failed_operations = []
	failed_operations_mutex = Mutex.new

	thread_info.map { |thread_value|
		Thread.new {
			first_time = true
			while true
				operation = operations_mutex.synchronize {
					operations.shift
				}
				break unless operation

				begin
					yield thread_value, operation, first_time
				rescue RuntimeError => exception
					operation[:exception] = exception
					failed_operations_mutex.synchronize {
						failed_operations << operation
					}
				end
				first_time = false
			end
		}
	}.each { |thread| thread.join }

	if not failed_operations.empty?
		puts
		failed_operations.each { |operation|
			puts "=> #{operation.inspect}"
		}
		print '=> '
		raise failed_operations[-1][:exception]
	end
end
