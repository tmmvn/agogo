# Copyright 2023, Tommi Venemies
# Licensed under the BSD-4-Clause.
class IniError < StandardError
	def initialize(c, m)
		@error_code = c
		@error_msg = m
	end

	def message
		"#{@error_code}: #{@error_msg}"
	end
end
