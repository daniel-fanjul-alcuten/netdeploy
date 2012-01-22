#!/usr/bin/env jruby

require 'tmpdir'

def mkworkdir
	Dir.mktmpdir(['work-', '.tmp'], '.') { |dir|
		yield dir
	}
end

def mkworkdirs num
	raise "#{num} not positive" if num < 1
	mkworkdir { |dir|
		if num == 1
				yield [dir]
		else
			mkworkdirs(num - 1) { |dirs|
				yield dirs + [dir]
			}
		end
	}
end
