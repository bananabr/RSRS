namespace :providers do
  namespace :SoftEther do
    def hub_mgmt_base_command(hub_name, hub_secret)
      "#{Settings.providers.soft_ether.vpncmd_path} #{Settings.providers.soft_ether.server}:#{Settings.providers.soft_ether.port} /SERVER /PASSWORD:#{hub_secret} /HUB:#{hub_name} /CMD"
    end
    namespace :hubs do

      desc "Create a new HUB in the configured SoftEther provider server"
      task :create, [:hub_name,:hub_secret] => :environment do |task, args|
        cmd = "#{Settings.providers.soft_ether.vpncmd_path} #{Settings.providers.soft_ether.server}:#{Settings.providers.soft_ether.port} " \
        "/SERVER /PASSWORD:#{Settings.providers.soft_ether.admin_hub_password} /CMD HubCreate #{args.hub_name} /PASSWORD:#{args.hub_secret}"
        Utils::execute_with_timeout!(cmd, 5)
      end

      desc "Deletes a HUB from the configured SoftEther provider server"
      task :delete, [:hub_name] => :environment do |task, args|
        cmd = "#{Settings.providers.soft_ether.vpncmd_path} #{Settings.providers.soft_ether.server}:#{Settings.providers.soft_ether.port} " \
        "/SERVER /PASSWORD:#{Settings.providers.soft_ether.admin_hub_password} /CMD HubDelete #{args.hub_name}"
        Utils::execute_with_timeout!(cmd, 5)
      end

      namespace :users do
        desc "Create a new HUB user in the configured SoftEther provider server"
        task :create, [:hub_name,:hub_secret,:username] => :environment do |task, args|
          cmd = "#{hub_mgmt_base_command(args.hub_name, args.hub_secret)} UserCreate #{args.username} /GROUP: /REALNAME: /NOTE:"
          Utils::execute_with_timeout!(cmd, 5)
        end

        desc "Set the password for a HUB user in the configured SoftEther provider server"
        task :set_password, [:hub_name,:hub_secret,:username,:password] => :environment do |task, args|
          cmd = "#{hub_mgmt_base_command(args.hub_name, args.hub_secret)} UserPasswordSet #{args.username} /PASSWORD:#{args.password}"
          Utils::execute_with_timeout!(cmd, 5)
        end

        desc "Set an expiration date of X seconds couting from now for a HUB user in the configured SoftEther provider server"
        task :set_expiration, [:hub_name,:hub_secret,:username,:seconds] => :environment do |task, args|
          expiration = (DateTime.now + args.seconds.to_i.seconds).strftime("%Y/%m/%d %H:%M:%S")
          cmd = "#{hub_mgmt_base_command(args.hub_name, args.hub_secret)} UserExpiresSet #{args.username} /EXPIRES:'#{expiration}'"
          Utils::execute_with_timeout!(cmd, 5)
        end
      end
    end

    namespace :tunnel do
      desc "Create VPN tunnels for support requests that use the SoftEther provider"
      task :create_pending => [:environment] do
        SupportRequest.not_expired.where(provider: "SoftEther").where(tunnel_created_at: nil).each do |req|
	  puts "Creating tunnel for request #{req.id}"
          cmds = []
          hub_name = "TEMP_#{req.shared_key}"
          hub_secret = req.shared_key
          user_expiration = (DateTime.now + 86400.seconds).strftime("%Y/%m/%d %H:%M:%S")

          cmds << "#{Settings.providers.soft_ether.vpncmd_path} #{Settings.providers.soft_ether.server}:#{Settings.providers.soft_ether.port} " \
          "/SERVER /PASSWORD:#{Settings.providers.soft_ether.admin_hub_password} /CMD HubCreate #{hub_name} /PASSWORD:#{hub_secret}"

          cmds << "#{hub_mgmt_base_command(hub_name, hub_secret)} UserCreate client /GROUP: /REALNAME: /NOTE:"
          cmds << "#{hub_mgmt_base_command(hub_name, hub_secret)} UserCreate support /GROUP: /REALNAME: /NOTE:"
          cmds << "#{hub_mgmt_base_command(hub_name, hub_secret)} UserPasswordSet client /PASSWORD:#{req.shared_key}"
          cmds << "#{hub_mgmt_base_command(hub_name, hub_secret)} UserPasswordSet support /PASSWORD:#{req.shared_key}"
          cmds << "#{hub_mgmt_base_command(hub_name, hub_secret)} UserExpiresSet client /EXPIRES:'#{user_expiration}'"
          cmds << "#{hub_mgmt_base_command(hub_name, hub_secret)} UserExpiresSet support /EXPIRES:'#{user_expiration}'"

          cmds << "#{hub_mgmt_base_command(hub_name, hub_secret)} SecureNatEnable"
          cmds << "#{hub_mgmt_base_command(hub_name, hub_secret)} NatDisable"
          cmds << "#{hub_mgmt_base_command(hub_name, hub_secret)} DhcpEnable"
          cmds << "#{hub_mgmt_base_command(hub_name, hub_secret)} DhcpSet /START:192.168.99.2 /END:192.168.99.3 /MASK:255.255.255.248 /GW: /DNS: /DNS2: /DOMAIN: /LOG:yes /EXPIRE:86400"

          cmds << "#{hub_mgmt_base_command(hub_name, hub_secret)} AccessAdd pass /MEMO:\"established\" /PRIORITY:10 " \
            "/SRCUSERNAME: /DESTUSERNAME: /SRCMAC: /DESTMAC: /SRCIP:\"0.0.0.0/0.0.0.0\" /DESTIP:\"0.0.0.0/0.0.0.0\" /PROTOCOL:tcp /SRCPORT:\"1024-65534\" /DESTPORT:\"1-65534\" /TCPSTATE:1"
          cmds << "#{hub_mgmt_base_command(hub_name, hub_secret)} AccessAdd pass /MEMO:\"allow all icmp\" /PRIORITY:20 " \
            "/SRCUSERNAME: /DESTUSERNAME: /SRCMAC: /DESTMAC: /SRCIP:\"0.0.0.0/0.0.0.0\" /DESTIP:\"0.0.0.0/0.0.0.0\" /PROTOCOL:icmpv4 /SRCPORT: /DESTPORT: /TCPSTATE:"
          cmds << "#{hub_mgmt_base_command(hub_name, hub_secret)} AccessAdd pass /MEMO:\"peers\" /PRIORITY:100 " \
            "/SRCUSERNAME: /DESTUSERNAME: /SRCMAC: /DESTMAC: /SRCIP:\"192.168.99.2/255.255.255.255\" /DESTIP:\"192.168.99.3/255.255.255.255\" /PROTOCOL:tcp /SRCPORT:\"1024-65534\" /DESTPORT:\"1-65534\" /TCPSTATE:0"
          cmds << "#{hub_mgmt_base_command(hub_name, hub_secret)} AccessAdd pass /MEMO:\"peers\" /PRIORITY:110 " \
            "/SRCUSERNAME: /DESTUSERNAME: /SRCMAC: /DESTMAC: /SRCIP:\"192.168.99.3/255.255.255.255\" /DESTIP:\"192.168.99.2/255.255.255.255\" /PROTOCOL:tcp /SRCPORT:\"1024-65534\" /DESTPORT:\"1-65534\" /TCPSTATE:0"
          cmds << "#{hub_mgmt_base_command(hub_name, hub_secret)} AccessAdd pass /MEMO:dhcp /PRIORITY:120 " \
            "/SRCUSERNAME: /DESTUSERNAME: /SRCMAC: /DESTMAC: /SRCIP:\"0.0.0.0/0.0.0.0\" /DESTIP:\"0.0.0.0/0.0.0.0\" /PROTOCOL:udp /SRCPORT:\"67-68\" /DESTPORT:\"67-68\" /TCPSTATE:"
          cmds << "#{hub_mgmt_base_command(hub_name, hub_secret)} AccessAdd discard /MEMO:\"cleanup\" /PRIORITY:1000 " \
            "/SRCUSERNAME: /DESTUSERNAME: /SRCMAC: /DESTMAC: /SRCIP:\"0.0.0.0/0.0.0.0\" /DESTIP:\"0.0.0.0/0.0.0.0\" /PROTOCOL:0 /SRCPORT: /DESTPORT: /TCPSTATE:"

          cmds.each do |cmd|
            Utils::execute_with_timeout!(cmd, 10)
          end

	  req.update!(tunnel_created_at: DateTime.now )

        end
      end
    end
  end
end
