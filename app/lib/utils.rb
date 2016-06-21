class Utils
	require 'timeout'

	def self.execute_with_timeout!(cmd, timeout=5)
		begin
			Timeout::timeout(timeout) do
				`#{cmd}`
				if $?.exited? && $?.exitstatus == 0
					true
				else
					raise RuntimeError
				end
			end
		end
	end

	def self.get_output_with_timeout!(cmd, timeout=5)
		begin
			Timeout::timeout(timeout) do
				result = `#{cmd}`
				if $?.exited? && $?.exitstatus == 0
					result
				else
					raise RuntimeError
				end
			end
		end
	end

	def self.execute_with_timeout(cmd, timeout=5)
		begin execute_with_timeout!(cmd, timeout) rescue false end
	end

	def self.get_output_with_timeout(cmd, timeout=5)
		begin get_output_with_timeout!(cmd, timeout) rescue nil end
	end

	def self.generate_random_string(length)
		seed = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
		(0...length).map{ seed[Random.rand(seed.length)] }.join
	end
end
