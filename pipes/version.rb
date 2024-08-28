require_relative 'pipe.rb'

# Provides a dynamic year-based version text. Version automatically goes to
# a param named version. So as a bare minimum, pipe in #version. Altenratively,
# you can pipe in a template where the spot for version is set.
# In addition, when piping, you can pass a dynamic version. Otherwise the
# value for version is read from global data passed in. The variable
# read is version. Version format is YYYY.MM.version.
class Version
	include Pipe

	def prime(d, i)
		version = Time.now.strftime("%Y.%m.")
		if i then
			@params["version"] = "#{version}#{i}"
		else
			@params["version"] = "#{version}#{d['version']}"
		end
	end
end
