class ApplicationController < ActionController::Base
	protect_from_forgery with: :exception
	helper_method :current_user
	helper_method :display_playlist
	
	def current_user
		@current_user ||= User.find(session[:user_id]) if session[:user_id]
	end
	
	def display_playlist
		
		playlists = Playlists.get_user_playlists(current_user)
		puts playlists
	
	end
	
	def self.print_user
	
	end

end