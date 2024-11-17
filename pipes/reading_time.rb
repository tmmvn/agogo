require(File.expand_path('pipe.rb', File.dirname(__FILE__)))

# Provides a time label for reading time based on word count of content piped
# in. Outputs the time to #readingtime
class ReadingTime
	include Pipe

	def close
		unless @in_conditional then
			w = params["content"].split.count
			ers = 228
			ens = 150
			rt = (w / ers).ceil
			nt = (w / ens).ceil
			rtstr = "<time aria-label='#{nt} minute listening time' "
			rtstr << "datetime='PT#{rt}M'>"
			rtstr << "#{rt} minute read"
			rtstr << "</time>"
			params["readingtime"] = rtstr
			@output << @params["content"]
			super
		end
	end

	def prime(d, i)
		@params["content"] = ""
	end

	def pipe(i)
		unless @in_conditional then
			#TODO: Ignore tags
			current_content = @params["content"]
			current_content << i
			current_content << "\n"
			@params["content"] = current_content
		end
	end

	def resume(i)
		unless @in_conditional then
			current_content = @params["content"]
			current_content << i
			current_content << "\n"
			@params["content"] = current_content
		end
	end
end
