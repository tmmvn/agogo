# Copyright 2023, Tommi Venemies
# Licensed under the BSD-4-Clause.
require_relative 'pipes.rb'
require_relative 'globaldata.rb'

# Parses .she (Shedio) files. These act as plans for the pipe
# system.
class Processor
	def initialize(ed, gd, pipes)
		@envdata = ed
		@globaldata = gd
		@pipes = pipes
		@target = "./#{@globaldata.data["target"]}"
		@source = "./#{@globaldata.data["source"]}"
		@activePipes = []
		@activeOutput = ""
		create_output_directories
	end

	def check_and_create_dir(d)
		unless Dir.exists? d
			require 'fileutils'
			FileUtils.mkdir_p d
		end
	end

	def create_output_directories
		check_and_create_dir @target
	end

	# The start point of parsing. Triggers a directory parse of the source
	# directory.
	def parse
		parse_directory @source
	end

	# Parses an env conditional row. This is indicated by a % in the .she
	# files. When encountering a %varname, if the variable exists in the
	# env.ini, the current active pipe receives a block signal. When
	# encountering a %end, the current active pipe receives an unblock
	# signal. When encountering a %varname foo, the block happens only if
	# the env.ini file has varname=foo in it. The varname foo combo is
	# provided as a parameter to the pipe for a chance to implement custom
	# logic.
	def parse_conditional(r)
		puts "Parsing conditional #{r}"
		if r.start_with? "%end"
			@activePipes.last.unblock
		else
			parsed = r.split "%", 2
			parts = parsed.last.split " ", 2
			param = parts.shift
			if parts.length == 0 then
				unless @envdata.data.has_key? param then
					@activePipes.last.block param
				end
			else
				if @envdata.data.has_key? param then
				value = parts[0].strip
					unless @envdata.data[param].to_s == value then
						@activePipes.last.block parsed.last
					end
				else
					# TODO: This needs to pass the parts
					@activePipes.last.block param
				end
			end
		end
	end

	# Parses a shedio (.she) file from source to target.
	# These files are pipe shematics that instruct on the processing of the
	# content. Triggers parse_pipe for logic.
	def parse_content(s, t)
		parse_pipe s
		if @activePipes.length != 0 then
			puts "Error. More than one pipe active when finishing."
			puts "You probably forgot to |end a pipe."
			#TODO Make actual error or remove if not actually fatal
		end
		target = File.dirname t
		check_and_create_dir target
		target << "/"
		target << File.basename(t, File.extname(t))
		# TODO: Figure out how to specify extension to pipe to.
		target << ".html"
		puts "Saving parsed #{s}, To: #{t}"
		File.open(target, "w") { |f| f.write @activeOutput }
	end

	# Walks the given directory. Anything starting with . or _ is ignored.
	# Triggers itself recursively if encounters a directory, otherwise
	# calls parse_file.
	def parse_directory(d)
		puts "Iterating #{d}"
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
			parse_file "#{d}/#{f}"
		end
		subdirs.each do |sd|
			parse_directory "#{d}/#{sd}"
		end
	end

	# Parses the given file. If the file is a shedio file (.she), it gets
	# processed with parse_content. Otherwise, the file is statically
	# copied to target, unless @extensions contains a class to handle the
	# processing. See parse_extension for details.
	def parse_file(s)
		puts "Processing #{s}"
		@activeOutput = ""
		target = File.dirname(s).sub!(@source, @target)
		target << "/"
		target << File.basename(s)
		case File.extname(s)
			when ".she"
				parse_content s, target
			else
				static_copy s, target
		end
	end

	# Parses a parameter row. This is indicated with a ^ in the .she files.
	# For example ^paramname foo. The currently active pipe is passed the
	# paramaname and then foo.
	def parse_param(s)
		param_parts = s.split " ", 2
		#puts "Parsing param: #{s}"
		@activePipes.last.pass_param param_parts.first.delete("^"), param_parts.last
	end

	# Processes passed file line by line passing each row to parse_row
	def parse_pipe(s)
		File.foreach(s) {
			|line|
			parse_row line
		}
	end

	# Parses the passed row for .she file logic. | triggers parse_tag,
	# ^ triggers parse_param, % triggers parse_conditional, otherwise
	# row is piped to the currently actived pipe.
	def parse_row(s)
		row = s.strip
		case
			when row.start_with?("|")
				parse_tag row
			when row.start_with?("^")
				unless @activePipes.empty?
					parse_param row
				end
			when row.start_with?("%")
				unless @activePipes.empty?
					parse_conditional row
				end
			else
				unless @activePipes.empty?
					@activePipes.last.pipe row
				end
		end
	end

	# Parses a row that had |. Example |pipename foo. Tries to find a pipe
	# called pipename and opens it passing in global data and foo. Adds
	# that pipe as the last pipe in the stack. If encounters |end, calls
	# tag_end
	def parse_tag(s)
		parts = s.split "|", 2
		tag_parts = parts.last.split
		tag = tag_parts.first.strip
		#puts "Parsing tag:#{tag}"
		if tag == "end"
			tag_end
			#puts @activePipes
		else
			if @pipes.pipes.has_key? tag
				pipe = @pipes.pipes[tag].new
				@activePipes.push pipe
				tag_parts.shift
				if tag_parts.length > 0 then
					@activePipes.last.prime @globaldata.data, tag_parts.join(" ")
				else
					@activePipes.last.prime @globaldata.data, nil
				end
				#puts @activePipes
			else
				puts "Pipe #{tag} not found"
			end
		end
	end

	# Does a static copy of source to target
	def static_copy(s, t)
		#puts "Copying #{s} to #{t}"
		check_and_create_dir File.dirname(t)
		File.open s, 'rb' do |input_stream|
			File.open t, 'wb' do |output_stream|
				IO.copy_stream input_stream, output_stream
			end
		end
	end

	# Closes current pipe and passes the output to the previous pipe in
	# stack. If no more pipes in stack, passes to @activeOutput.
	def tag_end
		activePipe = @activePipes.pop
		unless @activePipes.empty? then
			@activePipes.last.resume activePipe.close
		else
			@activeOutput << activePipe.close
		end
	end
end
