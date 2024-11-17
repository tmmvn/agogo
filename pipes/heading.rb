require(File.expand_path('pipe.rb', File.dirname(__FILE__)))

# Creates a heading. Takes the header level as input and puts everything piped
# in inside the block.
class Heading
	include Pipe

	def close
		super
		unless @in_conditional then
			@output << "</h#{params["level"]}>"
		end
	end

	def pipe(i)
		unless @in_conditional then
			@output << "#{i}"
		end
	end

	def prime(d, i)
		@params.merge!(d)
		@params["level"] = i
		unless @in_conditional then
			@output << "<h#{i}>"
		end
	end
end
