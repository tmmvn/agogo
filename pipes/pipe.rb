# Copyright 2023, Tommi Venemies
# Licensed under the BSD-4-Clause.
# Base pipe that all pipes should mixin and override as needed.
# As default, has single output, a hash for params, and state
# to see when blocked.
#
# When pipe is encountered in a .she-file (plan), prime is called with
# general site data (parsed by siteparser from .ini) and
# whatever input from the pipename row as params. The default
# implementation just passes the input to the output. The input is empty by default.
#
# When an |end is encountered in a .she-file (plan), close is called
# on the last activated pipe. The default replaces all params hash keys (#param_name) in
# the output with the value of the hash. Finally, the output is returned. The next pipe
# in the stack then gets a resume call with whatever the close returned.
#
# When a ^ is encountered in a .she-file (plan), the pass_param is called on the last
# activated pipe. First param is parameter name, second is anything after the param name
# in the .she-file. Default implementation saves these to params for replacing in close.
# Note that the default implementation adds # on its own.
#
# When a % is encountered in a .she-file (plan), the block method is called on the last
# activated pipe. By default, this checks the if params hash has the passed in key. If not,
# anything send to the pipe method will be ignored until %end. Otherwise, nothing happens.
#
# When a %end is encountered in a .she-file (plan), the unblock is called on the last
# activated pipe. By default, this resets the pipe ignore mode.
#
# Any row not starting with |, ^, or % will get sent to the pipe method of the last activated
# pipe. Default implementation adds this to the output.

module Pipe
	attr_accessor :output
	attr_accessor :params
	attr_accessor :in_conditional

	def initialize
		@output = ""
		@params = {}
		@in_conditional = false
	end

	def block(c)
		unless @params.has_key? c && @params[c] then
			@in_conditional = true
		end
	end

	def close
		@params.each {
			|key, value|
			@output.gsub!("##{key}", "#{value}")
			#puts "Applied param ##{key}: #{value}"
		}
		@output
	end

	def prime(d, i)
		@params.merge!(d)
		unless @in_conditional then
			@output << i
			@output << "\n"
		end
	end

	def pass_param(pr, v)
		unless @in_conditional then
			@params[pr] = v
		end
	end

	def pipe(i)
		unless @in_conditional then
			@output << i
			@output << "\n"
		end
	end

	def resume(i)
		unless @in_conditional then
			@output << i
			@output << "\n"
		end
	end

	def unblock
		@in_conditional = false
	end
end
