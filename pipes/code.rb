require(File.expand_path('pipe.rb', File.dirname(__FILE__)))

# Creates a preformatted code block. Takes code language as input and adds
# everything piped in to the block.
class Code
	include Pipe

	def close
		super
		unless @in_conditional then
			@output << "</pre>"
		end
	end

	def pipe(i)
		unless @in_conditional then
			@output << "#{i}"
		end
	end

	def prime(d, i)
		@params.merge!(d)
		@params["language"] = i
		unless @in_conditional then
			@output << "<pre>"
		end
	end
end
