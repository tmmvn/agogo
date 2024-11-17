require(File.expand_path('pipe.rb', File.dirname(__FILE__)))

# Creates an external link to the input link. Adds an adjoining icon as indicator.
class ExternalLink
	include Pipe

	# TODO: Update icon font to svg img
	def pipe(i)
		unless @in_conditional then
			@output << "<a href='#{@params["link"]}' target='_blank' "
			@output << "rel='nofollow noreferrer' "
			@output << "aria-label='#{i} Opens in new tab or window.'>"
			@output << "#{i}"
			@output << "<sup><i aria-hidden='true' class='icon-inline'>"
			@output << "&#xf08e"
			@output << "</i></sup></a>"
		end
	end

	def prime(d, i)
		@params.merge!(d)
		@params["link"] = i
	end
end
