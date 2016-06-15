class ApplicationController < ActionController::Base
	rescue_from DeviseLdapAuthenticatable::LdapException do |exception|
		render :text => exception, :status => 500
	end
	# Prevent CSRF attacks by raising an exception.
	# For APIs, you may want to use :null_session instead.
	protect_from_forgery with: :exception

	before_action :set_limit, only:[:index]
	before_action :set_offset, only:[:index]

	private
	def set_limit
		@limit = params.has_key?(:limit) ? params[:limit].to_i : -1
	end

	def set_offset
		@skip = params.has_key?(:skip) ? params[:skip].to_i : 0
	end
end
