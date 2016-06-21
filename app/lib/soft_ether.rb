require "utils.rb"

module SoftEther
	class Hub
		class User
			def initialize(name, hub)
				@name = name
				@hub = hub
				@password = nil
				@expiration_date = nil
			end

			def set_password!(password)
				@hub.execute_command!("UserPasswordSet #{@name} /PASSWORD:#{password}")
				@password = password
			end

			def set_expiration_date!(sec)
				user_expiration = (DateTime.now + sec).strftime("%Y/%m/%d %H:%M:%S")
				@hub.execute_command!("UserExpiresSet client /EXPIRES:'#{user_expiration}'")
				@expiration_date = exp
			end
		end

		def initialize(name,server,password=nil)
			@name = name
			@server = server
			@password = password
			@users = {}
			@users_cache_dirty = true
		end
		
		def set_password(p)
			@password = p 
		end

		def create_user!(name)
			execute_command!("UserCreate #{name} /GROUP: /REALNAME: /NOTE:")
			@users[name] = User.new(name,self)
		end

		def get_users!()
			if  users_cache_is_dirty?
				output = execute_command_with_output!("UserList")
				output.each_line do |line|
					if line.include?('|')
						key,val = line.split('|')
						if key =~ /.*User.*Name.*/
							user_name = val.strip.chomp
							@users[user_name] = SoftEther::Hub::User.new(user_name,self)
						end
					end
				end
				update_users_cache
				@users
			else
				@users
			end
		end

		protected
		def execute_command!(command_suffix)
			cmd = "#{hub_mgmt_base_command} #{command_suffix}"
		        Utils::execute_with_timeout!(cmd, @server.timeout)
		end
		def execute_command_with_output!(command_suffix)
			cmd = "#{hub_mgmt_base_command} #{command_suffix}"
		        Utils::get_output_with_timeout!(cmd, @server.timeout)
		end

		private
		def hub_mgmt_base_command()
			"#{@server.vpncmd_bin_path} #{@server.host}:#{@server.port} /SERVER /HUB:#{@name} /PASSWORD:#{@password} /CMD"
		end
		def users_cache_is_dirty?()
			@users_cache_dirty
		end
		def update_users_cache()
			@users_cache_dirty = false
		end
		def dirty_users_cache()
			@users_cache_dirty = true
		end
	end

	class Server
		def initialize(host='localhost',options={:port => 443, :password => '', :vpncmd_bin_path => '/usr/local/bin/vpncmd', :timeout => 5})
			@host = host
			@port = options[:port].present? ? options[:port] : 443
			@password = options[:password].present? ? options[:password] : ''
			@vpncmd_bin_path = options[:vpncmd_bin_path].present? ? options[:vpncmd_bin_path] : '/usr/local/bin/vpncmd'
			@timeout = options[:timeout].present? ? options[:timeout] : 5
			@hubs = {}
			@hub_cache_dirty = true
		end

		def host
			@host
		end	
		def port
			@port
		end	
		def timeout
			@timeout
		end	
		def vpncmd_bin_path
			@vpncmd_bin_path
		end

		def create_hub!(hub_name, hub_password="Soft#eth3r")
		        cmd = "#{@vpncmd_bin_path} #{@host}:#{@port} /SERVER /PASSWORD:#{@password} /CMD HubCreate #{hub_name} /PASSWORD:#{hub_password}"
		        Utils::execute_with_timeout!(cmd, @timeout)
			@hubs[hub_name] = SoftEther::Hub.new(hub_name, self, hub_password)
			dirty_hub_cache
			@hubs[hub_name]
		end
	
		def delete_hub!(hub_name)
		        cmd = "#{@vpncmd_bin_path} #{@host}:#{@port} /SERVER /PASSWORD:#{@password} /CMD HubDelete #{hub_name}"
		        Utils::execute_with_timeout!(cmd, @timeout)
			@hubs.delete(hub_name)
			dirty_hub_cache
			true
		end

		def hubs
			self.get_hubs!
		end	
		def get_hubs!()
			if  hub_cache_is_dirty?
			        cmd = "#{@vpncmd_bin_path} #{@host}:#{@port} /SERVER /PASSWORD:#{@password} /CMD HubList"
			        output = Utils::get_output_with_timeout!(cmd, @timeout)
				output.each_line do |line|
					if line.include?('|')
						key,val = line.split('|')
						if key =~ /.*Hub.*Name.*/
							hub_name = val.strip.chomp
							@hubs[hub_name] = SoftEther::Hub.new(hub_name,self)
						end
					end
				end
				update_hub_cache
				@hubs
			else
				@hubs
			end
		end
	
		private
		def hub_cache_is_dirty?()
			@hub_cache_dirty
		end
		def update_hub_cache()
			@hub_cache_dirty = false
		end
		def dirty_hub_cache()
			@hub_cache_dirty = true
		end
	end
end
