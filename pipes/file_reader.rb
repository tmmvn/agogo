require_relative 'pipe.rb'

# Reads a file and pipes its contents out without processing.
class FileReader
	include Pipe

	def prime(d, i)
		filename = "#{i}"
		puts "Loading file: #{i}"
		return "" unless File.file?(filename)
		parse_file filename
		@output = ""
	end

	def parse_file(s)
		File.foreach(s) {
			|content|
			row = content.strip
			@output << row
		}
		puts "...Loaded File."
	end

	def pipe(i)
		puts "File reader ignores piped content"
	end

	def resume(i)
		unless @in_conditional then
			@output << i
		end
	end
end
