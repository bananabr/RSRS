class User < ActiveRecord::Base
	# Include default devise modules. Others available are:
	# :confirmable, :lockable, :timeoutable, :rememberable and :omniauthable
	devise :ldap_authenticatable, :rememberable, :trackable
	attr_accessible :username, :email, :password, :password_confirmation, :remember_me, :firstname, :lastname, :displayname
	has_many :support_requests

	before_save :get_ldap_lastname, :get_ldap_firstname, :get_ldap_displayname, :get_ldap_email

	validates :username, presence: true, uniqueness: true

	#hack for remember_token
	def rememberable_value
		Digest::SHA1.hexdigest("#{self.email}#{self.username}")[0,29]
	end

	private
	def get_ldap_lastname
		Rails::logger.info("### Getting the users last name")
		tempname = Devise::LDAP::Adapter.get_ldap_param(self.username,"sn").first
		puts "\tLDAP returned lastname of " + tempname
		self.lastname = tempname
	end

	def get_ldap_firstname
		Rails::logger.info("### Getting the users first name")
		tempname = Devise::LDAP::Adapter.get_ldap_param(self.username,"givenName").first
		puts "\tLDAP returned firstname of " + tempname
		self.firstname = tempname
	end

	def get_ldap_displayname
		Rails::logger.info("### Getting the users display name")
		tempname = Devise::LDAP::Adapter.get_ldap_param(self.username,"displayName").first
		self.displayname = tempname
	end

	def get_ldap_email
		Rails::logger.info("### Getting the users email address")
		tempmail = Devise::LDAP::Adapter.get_ldap_param(self.username,"proxyAddresses").first.split(":")[1]
		self.email = tempmail
	end
end
