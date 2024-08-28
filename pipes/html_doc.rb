require_relative 'pipe.rb'

# Creates a HTML doc. Should be your starting pipe most of the time.
class HtmlDoc
	include Pipe

	def close
		super
		unless @in_conditional then
			@output << "</html>"
		end
	end

	def prime(d, i)
		@params.merge!(d)
		unless @in_conditional then
			@output << "<!doctype html>"
			@output << "<html lang='#language_code'>"
		end
		#@output << i
	end
end
