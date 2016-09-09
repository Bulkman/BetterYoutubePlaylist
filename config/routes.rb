#Rails.application.routes.draw do
  #get 'sessions/create'

  #get 'sessions/destroy'

  #get 'home/show'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
#end

BetterYoutubePlaylist::Application.routes.draw do
  root to: "application#index"
  
  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure',            to: redirect('/')
  get 'signout',                 to: 'sessions#destroy', as: 'signout'
  
  resources :sessions, only: [:create, :destroy]
end
