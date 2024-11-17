require(File.expand_path('pipe.rb', File.dirname(__FILE__)))

# Provides a dynamic year-based copyright. The copyright automatically goes to
# a param copyright. So as a bare minimum, pipe in #copyright. Alternatively,
# you can pipe in a template where the spot for copyright is set.
# In addition, when piping, you can pass a dynamic copyright. Otherwise the
# value for copyright holder is read from global data passed in. The variable
# read is copyright_holder.
class Copyright
	include Pipe

	def prime(d, i)
		@params.merge!(d)
		year = Time.new.year
		if i then
			@params["copyright"] = "Copyright (c) #{year} #{i}"
		else
			@params["copyright"] = "Copyright (c) #{year} #{d['copyright_holder']}"
		end
	end
end
