require(File.expand_path('pipe.rb', File.dirname(__FILE__)))

# TODO: Implement
class Listing
	include Pipe

	def close
		@listings.each {
			|item|
			li = @params["li"]
			li.gsub!("#listing", "#{item}")
		}
	end

	def prime(d, i)
		@listing_dir = i
		@listings = []
		populate_listing
	end

	def populate_listing
		walk_dir @listing_dir
	end

	def pipe(i)
		unless @in_conditional then
			@output << i
		end
	end

	def resume(i)
		unless @in_conditional then
			@output << i
		end
	end

	def walk_dir(d)
		contents = Dir.children d
		subdirs = contents.reject {
			|c|
			!Dir.exist?(File.expand_path(c, d)) || c.start_with?(".", "_")
		}
		files = contents.reject {
			|c|
			Dir.exist?(File.expand_path(c, d)) || c.start_with?(".", "_")
		}
		files.each do |f|
			listings.push "#{d}/#{f}"
		end
		subdirs.each do |sd|
			walk_dir "#{d}/#{sd}"
		end
	end
end
