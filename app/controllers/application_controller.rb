require 'rest-client'
require 'json'

class ApplicationController < ActionController::Base
	#protect_from_forgery with: :exception
	helper_method :current_user
	helper_method :get_playlists
	helper_method :reset_auth_token
	helper_method :current_playlist_id
	helper_method :playlist_items
	
	################################
	###### VARIABLES GET & SET #####
	################################
	
	def current_playlist_id
		@current_playlist_id
	end
	
	def current_user
		@current_user ||= User.find(session[:user_id]) if session[:user_id]
	end
	
	############################
	###### UTILITY METHODS #####
	############################
	
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
						playlists_info.each { |entry| res << entry }
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
	
	def playlist_items(token = "")
		res = []
		if current_user && current_user.oauth_token.length > 0
			RestClient.get(
				"https://www.googleapis.com/youtube/v3/playlistItems",
				:params => {
					:part          => "snippet",
					:playlistId    => @current_playlist_id,
					:maxResults    => 50,
					:pageToken 	   => token,
					:key           => "AIzaSyBfjsc4qFp_BkhjZ9PQgbxTwfzRAeUvmoM",
					:access_token  => current_user.oauth_token
				}
			) { |response, request, result, &block|
				case response.code
					when 200
						playlists_info = JSON.parse(response.to_str)
						old_token = token
						token = playlists_info["nextPageToken"]
						playlist_items_array = playlists_info["items"]
						
						if playlist_items_array != nil
							playlist_items_array.each { |entry| res << entry["snippet"] }
						end
						
						if playlists_info.has_key?("nextPageToken") && old_token != token
							res.concat playlist_items(token)
						end
					
					else
						res.clear
						res << "Result: #{result}".html_safe
						res << "Response: #{response.to_str}".html_safe
						res << "Request: #{request}".html_safe
						res << "Headers: #{response.raw_headers}".html_safe
				end
			}
		end
		res
	end
	
	def reset_auth_token
		RestClient.get(
			"https://accounts.google.com/o/oauth2/revokes",
			:params => {
				:token => current_user.oauth_token
			}
		)
	end
	
	######################################
	###### USER ACTION METHODS BELOW #####
	######################################
	def index
		render "layouts/application"
	end
	
	def playlist
		@current_playlist_id = params[:playlist_id]
		
		#render(:template => 'content/_playlist')
		respond_to do |format|
			format.js { render layout: false, content_type: 'text/javascript', :template => "content/playlist" }
		end
	end
end