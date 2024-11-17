require(File.expand_path('pipe.rb', File.dirname(__FILE__)))

# Provides support for adding an image tag, but only if the image
# file passed exists.
# TODO: Implement
class Image
	include Pipe

	def prime(d, i)
		@template_dir = d["templates"]
		filename = "#{@template_dir}/#{i}.prot"
		puts "Loading template: #{filename}"
		return "" unless File.file?(filename)
		parse_template filename
		@params["content"] = ""
	end

	def parse_template(s)
		File.foreach(s) {
			|content|
			row = content.strip
			if row.start_with?("~")
				parts = row.split "~", 2
				filename = "#{@template_dir}/#{parts.last}.prot"
				puts "Loading subtemplate: #{filename}"
				parse_template filename
			elsif row.start_with?("^")
				param_parts = row.split " ", 2
				#puts "Adding param: #{row}"
				@params[param_parts.first.delete("^")] = param_parts.last
			else
				@output << content
			end
		}
		puts "...Loaded template."
	end

	def pipe(i)
		unless @in_conditional then
			current_content = @params["content"]
			current_content << i
			@params["content"] = current_content
		end
	end

	def resume(i)
		unless @in_conditional then
			current_content = @params["content"]
			current_content << i
			@params["content"] = current_content
		end
	end
end
