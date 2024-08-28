require_relative 'pipe.rb'

# Creates a download link to the input file with a download icon attached.
class DownloadLink
	include Pipe

	# TODO: Update icon font to svg img
	def pipe(i)
		unless @in_conditional then
			@output << "<a href='#{@params["dl_dir"]}/#{@params["link"]}' "
			@output << "aria-label='#{i}'. Opens a pdf file download.'>"
			@output << "#{i}"
			@output << "<sup><i aria-hidden='true' class='icon-inline'>"
			@output << "&#xf019"
			@output << "</i></sup></a>"
		end
	end

	def prime(d, i)
		@params.merge!(d)
		@params["link"] = i
	end
end
