# Copyright 2023, Tommi Venemies
# Licensed under the BSD-4-Clause.
require_relative 'include/iniparser.rb'

# Loads all pipes defined in pipes.ini from the configured pipes directory.
# This allows using |pipename in the .she files to load and pipe contents to
# the named pipe. Pipe names are lowercased from the pipe's Ruby Class Name.
class Pipes
	attr_accessor :pipes
	def initialize(pp)
		parser = IniParser.new
		included_pipes = parser.feed 'pipes.ini'
		@pipes = {}
		included_pipes.each do |section, parameter, value|
			#puts "#{parameter} = #{value} [in section - #{section}]"
			require "./#{pp}/#{parameter}.rb"
			pipe_class = Object.const_get value
			@pipes[value.downcase] = pipe_class
		end
	end
end
