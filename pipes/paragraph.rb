require_relative 'pipe.rb'

# Creates a paragraph block. Everything piped in goes to the paragraph.
class Paragraph
	include Pipe

	def close
		super
		unless @in_conditional then
			@output << "</p>"
		end
	end

	def pipe(i)
		unless @in_conditional then
			@output << "#{i}"
		end
	end

	def prime(d, i)
		@params.merge!(d)
		unless @in_conditional then
			@output << "<p>"
		end
	end
end
