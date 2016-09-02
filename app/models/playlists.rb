require 'rest-client'
require 'json'

class Playlists
	
	attr_reader :playlists_info
	
	def initialize
		@playlists_info = []
	end
	
	def self.get_user_playlists(user)
			response = RestClient.get("https://www.googleapis.com/youtube/v3/playlists", params: {:part => "snippet", :key => "AIzaSyBfjsc4qFp_BkhjZ9PQgbxTwfzRAeUvmoM", :access => user.oauth_token}).to_str
			@playlists_info = JSON.parse(response)["items"]
		
		return @playlists_info
	end
	
end