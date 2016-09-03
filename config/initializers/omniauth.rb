OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
	provider :google_oauth2, "296473228932-2stolrcmus6rlv2efi3218umpr026cmq.apps.googleusercontent.com", "kAFGvMEsCBFINL_QFOq0bi-I", {
		:client_options => {
			:ssl => {
				:ca_file => "#{Rails.root}/lib/ca-bundle.crt"
			}
		},
		:scope          => "https://www.googleapis.com/auth/userinfo.email, https://www.googleapis.com/auth/userinfo.profile, https://www.googleapis.com/auth/youtube, https://www.googleapis.com/auth/youtube.readonly",
		:prompt 		=> "select_account consent",
	}
end