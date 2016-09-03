require 'rest-client'
require 'json'

class ApplicationController < ActionController::Base
	protect_from_forgery with: :exception
	helper_method :current_user
	helper_method :get_playlists
	
	def current_user
		@current_user ||= User.find(session[:user_id]) if session[:user_id]
	end
	
	# https://developers.google.com/youtube/v3/docs/playlists/list#response
	def get_playlists
		res = []
		
		if current_user && current_user.oauth_token.length > 0
			RestClient.get(
				"https://www.googleapis.com/youtube/v3/playlists",
				:params => {
					:part         => "snippet",
					:mine         => true,
					:key          => "AIzaSyBfjsc4qFp_BkhjZ9PQgbxTwfzRAeUvmoM",
					:access_token => current_user.oauth_token
				}
			){ |response, request, result, &block|
				case response.code
					when 200
						playlists_info = JSON.parse(response.to_str)["items"]
						playlists_info.each { |entry| res << entry["snippet"]["localized"]["title"].html_safe }
					else
						res << "Result: #{result}".html_safe
						res << "Response: #{response.to_str}".html_safe
						res << "Request: #{request}".html_safe
						res << "Headers: #{response.raw_headers}".html_safe
				end
			}
		end
		
		res
	end
end