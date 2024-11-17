# Copyright 2023, Tommi Venemies
# Licensed under the BSD-4-Clause.
require(File.expand_path('inifile.rb', File.dirname(__FILE__)))
require(File.expand_path('inierror.rb', File.dirname(__FILE__)))

class IniParser
	def initialize(ro = {})
		configure ro
	end

	def configure(ro = {})
		sym_c = ro.fetch :comments, ';#'
		exp_comment = sym_c.to_s.empty? ? "\\z" : "\\s*(?:[#{sym_c}].*)?\\z"
		@delimiter = ro.fetch :delimiter, '='
		@default_section = ro.fetch :default_section, 'global'
		@exp_close_quote = %r/\A(.*(?<!\\)")#{exp_comment}/
		@exp_full_quote = %r/\A\s*(".*(?<!\\)")#{exp_comment}/
		@exp_ignore = %r/\A#{exp_comment}/
		@exp_leading_quote = %r/\A"/
		@exp_normal_value = %r/\A(.*?)#{exp_comment}/
		@exp_open_quote = %r/\A\s*(".*)\z/
		@exp_property = %r/\A(.*?)(?<!\\)#{@delimiter}(.*)\z/
		@exp_section = %r/\A\s*\[([^\]]+)\]#{exp_comment}/
		@exp_trailing_slash = %r/\A(.*)(?<!\\)\\#{exp_comment}/
	end

	def error(l)
		raise IniError.new "IE02", "Error on line: #{l.inspect}"
	end

	def feed(f, e = nil)
		return nil unless File.file?(f)
		ini = IniFile.new @delimiter
		mode = e ? "r:#{e}" : "r"
		File.open(f, mode) { |content| parse content, ini }
		ini
	end

	def parse(c, t)
		return unless c && t
		current_property = nil
		current_section = t[@default_section]
		previous = nil
		c.each_line do |line|
			parse_line current_section, current_property, line, previous
		end
		if previous
			raise IniError.new "IE05", "Dangling data left behind"
		end
	end

	def parse_line(cs, cp, l, lo)
		line = l.chomp
		if lo
			lo = parse_value line, cs, cp, lo
		else
			case line
				when @exp_ignore
					nil
				when @exp_section
					cs = cs[$1]
					nil
				when @exp_property
					cp = $1.strip
					error l if cp.empty?
					lo = parse_value $2, cs, cp
				else
					error l
			end
		end
	end

	def parse_value(i, cs, cp, lo = nil)
		value = ""
		if lo != nil then value = lo
		end
		if i =~ @exp_leading_quote
			if i =~ @exp_close_quote
				value << $1
				value = save_property cs, cp, value
			else
				value << i
				value << $/ if value =~ @exp_leading_quote
			end
		else
			case i
				when @exp_full_quote
					value = save_property cs, cp, $1
				when @exp_open_quote
					value = $1
				when @exp_trailing_slash
					value << $1
				when @exp_normal_value
					value << $1
					value = save_property cs, cp, value
				else
					error i
			end
		end
		value
	end

	def save_property(s, pr, v)
		pr.strip!
		v.strip!
		v = $1 if v =~ %r/\A"(.*)(?<!\\)"\z/m
		s[pr] = typecast v
		nil
	end

	def typecast(v)
		case v
			when %r/\Atrue\z/i
				true
			when %r/\Afalse\z/i
				false
			when %r/\A\s*\z/i
				nil
			else
				stripped_value = v.strip
				if stripped_value =~ /^\d*\.\d+$/
					Float stripped_value
				elsif stripped_value =~ /^[^0]\d*$/
					Integer stripped_value
				else
					unescape v
				end
		end
		rescue
			unescape v
	end

	def unescape(v)
		value = v.to_s
		value.gsub!(%r/\\[0nrt\\]/) {
			|char|
			case char
				when '\0'
					"\0"
				when '\n'
					"\n"
				when '\r'
					"\r"
				when '\t'
					"\t"
				when '\\\\'
					"\\"
			end
		}
		value
	end
end
