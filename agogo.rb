#!/usr/bin/env ruby
# Copyright 2023, Tommi Venemies
# Licensed under the BSD-4-Clause.

require_relative 'src/envdata.rb'
require_relative 'src/globaldata.rb'
require_relative 'src/pipes.rb'
require_relative 'src/processor.rb'

# Agogo is a file processor that walks a source directory and processes or
# copies files to a target dir. The app makes some assumptions. You
# are expected to provide env.ini, global.ini, and pipes.ini configuration
# files. The app handles .she files with a special case. See app.rb for details
class Agogo
	def process
		envData = EnvData.new
		globalData = GlobalData.new
		pipes = Pipes.new globalData.data["pipes"]
		parser = Processor.new envData, globalData, pipes
		parser.parse
	end
end

if __FILE__ == $0
	app = Agogo.new
	app.process
end
