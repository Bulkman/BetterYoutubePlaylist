require 'rest-client'
require 'json'

class Playlists
	
	attr_reader :playlists_info
	
	def initialize
		@playlists_info = []
	end
	
	def self.get_user_playlists(user)
		if user
			response = RestClient.get("https://www.googleapis.com/youtube/v3/playlists", {:params => {:part => "snippet"}})
			@playlists_info = JSON.parse(response)["items"]
		else
			@playlists_info = []
		end
		
		return self
	end
	
end