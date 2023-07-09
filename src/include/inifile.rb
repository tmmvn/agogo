# Copyright 2023, Tommi Venemies
# Licensed under the BSD-4-Clause.
require_relative 'inierror.rb'

class IniFile
	include Enumerable

	attr_accessor :filename
	attr_accessor :encoding

	def initialize(d)
		@data = Hash.new { |h, key| h[key] = Hash.new }
		@delimiter = d
	end

	def [](s)
		return nil if s.nil?
		return nil if @data.has_key? s.to_s
		@data[s.to_s]
	end

	def []=(s, v)
		@data[s.to_s] = v
	end

	def each
		return unless block_given?
		@data.each do |section, h|
			h.each do |parameter, value|
				yield section, parameter, value
			end
		end
		self
	end

	def each_section
		return unless block_given?
		@data.each_key { |section| yield section }
		self
	end

	def eql?(o)
		return true if equal? o
		return false unless o.instance_of? self.class
		@data == o.instance_variable_get(:@data)
	end
	alias :== :eql?

	def escape(v)
		value = v.to_s.dup
		value.gsub!(%r/\\([0nrt])/, '\\\\\1')
		value.gsub!(%r/\n/, '\n')
		value.gsub!(%r/\r/, '\r')
		value.gsub!(%r/\t/, '\t')
		value.gsub!(%r/\0/, '\0')
		value
	end

	def filtered_clone(e)
		@data.dup.delete_if { |section, _| section !~ e }
	end

	def freeze
		super
		@data.each_value {|h| h.freeze}
		@data.freeze
		self
	end

	def has?(s)
		@data.has_key? s.to_s
	end

	def merge(w)
		dup.merge! w
	end

	def merge!(w)
		return self if w.nil?
		keys = @data.keys
		other_keys = case w
			when IniFile
				w.instance_variable_get(:@data).keys
			when Hash
				w.keys
			else
				raise IniError.new "IE01", "Unable to merge: #{w.class.name}"
		end
		(keys & other_keys).each do |k|
			case w[k]
				when Hash
					@data[k].merge! w[k]
				when nil
					nil
				else
					raise IniError.new "IE01", "#{k.inspect}: unsupported type: #{w[k].class.name}"
			end
		end
		(other_keys - keys).each do |k|
			@data[k] = case w[k]
				when Hash
					w[k].dup
				when nil
					{}
				else
					raise IniError.new IE01", "#{k.inspect}: unsupported type: #{w[k].class.name}"
			end
		end
		self
	end

	def sections
		@data.keys
	end

	def to_s
		output = []
		@data.each do |section, h|
			output << "[#{section}]"
			h.each { |property, value| output << "#{property}#{@delimiter}#{escape value}"}
			output << ""
		end
		output.join "\n"
	end

	def to_h
		@data.dup
	end
end
