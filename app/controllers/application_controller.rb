require 'rest-client'
require 'json'

class ApplicationController < ActionController::Base
	#protect_from_forgery with: :exception
	helper_method :current_user
	helper_method :reset_auth_token
	helper_method :playlists
	
	before_action :start
	
	API_KEY = "AIzaSyBfjsc4qFp_BkhjZ9PQgbxTwfzRAeUvmoM"
	CLIENT_ID = "296473228932-2stolrcmus6rlv2efi3218umpr026cmq.apps.googleusercontent.com"
	SECRET_KEY = "kAFGvMEsCBFINL_QFOq0bi-I"
	
	###############################
	##### VARIABLES GET & SET #####
	###############################
	
	def playlists
		@playlists
	end
	
	def current_user
		@current_user ||= User.find(session[:user_id]) if session[:user_id]
	end
	
	###########################
	##### UTILITY METHODS #####
	###########################
	
	def start
		@playlists = download_playlists
		refresh_token_if_expired
	end
	
	# https://developers.google.com/youtube/v3/docs/playlists/list#response
	def download_playlists
		res = []
		
		if current_user && current_user.oauth_token.length > 0
			if refresh_token_if_expired != "OK"
				return res
			end
			
			RestClient.get(
				"https://www.googleapis.com/youtube/v3/playlists",
				:params => {
					:part         => "snippet",
					:mine         => true,
					:key          => API_KEY,
					:access_token => current_user.oauth_token
				}
			){ |response, request, result, &block|
				case response.code
					when 200
						playlists_info = JSON.parse(response.to_str)
						playlists_info["items"].each { |entry|
							entry["content"] = download_playlist_items(entry["id"])
							res << entry
						}

					else
						error = ""
						error << "Result: #{result}".html_safe
						error << "Response: #{response.to_str}".html_safe
						error << "Request: #{request}".html_safe
						error << "Headers: #{response.raw_headers}".html_safe
						puts error
				end
			}
		end
		
		res
	end
	
	# https://developers.google.com/youtube/v3/docs/playlistItems/list
	def download_playlist_items(id_p, token = "")
		res = []
		
		if current_user && current_user.oauth_token.length > 0
			if refresh_token_if_expired != "OK"
				return res
			end
			
			RestClient.get(
				"https://www.googleapis.com/youtube/v3/playlistItems",
				:params => {
					:part          => "snippet",
					:playlistId    => id_p,
					:maxResults    => 50,
					:pageToken 	   => token,
					:key           => API_KEY,
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
							res.concat download_playlist_items(token)
						end
					
					else
						error = ""
						error << "Result: #{result}".html_safe
						error << "Response: #{response.to_str}".html_safe
						error << "Request: #{request}".html_safe
						error << "Headers: #{response.raw_headers}".html_safe
						puts error
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
	
	def refresh_token_if_expired
		res = "OK"
		
		if Time.at(current_user.oauth_expires_at) < Time.now
			data = {
				:client_id => CLIENT_ID,
				:client_secret => SECRET_KEY,
				:refresh_token => current_user.refresh_token,
				:grant_type => "refresh_token"
			}
			
			RestClient.post("https://accounts.google.com/o/oauth2/token", data) { |response, request, result, &block|
				case response.code
					when 200
						response = JSON.parse(response.to_str)
						if response["access_token"].present?
							current_user.oauth_token = response["access_token"]
						end
					else
						res << "Result: #{result}\n"
						res << "Response: #{response.to_str}\n"
						res << "Request: #{request}\n"
						res << "Headers: #{response.raw_headers}\n"
						puts res
				end
			}
		end
	
		res
	end
	
	#####################################
	##### USER ACTION METHODS BELOW #####
	#####################################
	
	def index
		render :layout => false, :template => "layouts/application"
	end
end