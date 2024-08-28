require_relative 'pipe.rb'

# Allows bypassing anything piped in
class Comment
	include Pipe

	def close
		return ""
	end

	def prime(d, i)
	end

	def pass_param(pr, v)
	end

	def pipe(i)
		#puts "Commenting #{i}"
	end
end
