# Copyright 2023, Tommi Venemies
# Licensed under the BSD-4-Clause.
require(File.expand_path('include/iniparser.rb', File.dirname(__FILE__)))

# GlobalData holds data provided to each pipe when the pipe is opened.
class GlobalData
	attr_accessor :data

	def initialize
		@data = {}
		parser = IniParser.new
		globalData = parser.feed 'global.ini'
		globalData.each do |section, parameter, value|
			@data[parameter] = value
		end
	end
end
