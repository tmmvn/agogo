require_relative 'pipe.rb'

# Creates a List. Takes the header level as input and puts everything piped
# in inside the block.
# TODO: Implement
class List
	include Pipe

	def close
		super

		@output << "</h#{params["level"]}>"
	end

	def pipe(i)
		unless @in_conditional then
			@output << "#{i}"
		end
	end

	def prime(d, i)
		@params.merge!(d)
		@params["level"] = i
		# TODO: Switch on params level
		@output << "<h#{i}>"
	end
end
