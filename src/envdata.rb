# Copyright 2023, Tommi Venemies
# Licensed under the BSD-4-Clause.
require(File.expand_path('include/iniparser.rb', File.dirname(__FILE__)))

# Env data holds enviromental data that can be used to control processing using
# % inside .she files.
class EnvData
	attr_accessor :data

	def initialize
		@data = {}
		parser = IniParser.new
		envData = parser.feed 'env.ini'
		envData.each do |section, parameter, value|
			@data[parameter] = value
		end
	end
end
