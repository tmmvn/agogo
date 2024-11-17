require(File.expand_path('pipe.rb', File.dirname(__FILE__)))

# Provides support for protypo (.prot) templates.
# Protypo files should be basic HTML files of reusable
# components. You can use #param_name to replace values
# in the files dynamically. You can pipe content
# to the template pipe before closing to replace #content
# automatically. You can use ~ inside the templates to
# include another component template.
class Template
	include Pipe

	def prime(d, i)
		@template_dir = d["templates"]
		filename = "#{@template_dir}/#{i}.prot"
		puts "Loading template: #{filename}"
		# TODO: Check why this didn't block
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
			#current_content << "\n"
			@params["content"] = current_content
		end
	end

	def resume(i)
		unless @in_conditional then
			current_content = @params["content"]
			current_content << i
			#current_content << "\n"
			@params["content"] = current_content
		end
	end
end
