# Copyright 2023, Tommi Venemies
# Licensed under the BSD-4-Clause.
require_relative 'include/iniparser.rb'

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
