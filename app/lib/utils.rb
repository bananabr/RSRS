class Utils
	def self.generate_random_string(length)
		seed = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
		(0...length).map{ seed[Random.rand(seed.length)] }.join
	end
end
