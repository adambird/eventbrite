Rails.application.routes.draw do

  root 'main#index'
  post 'sync', to: 'main#sync'

  get '/auth/:provider/callback', to: 'sessions#create'
  get '/auth/failure', to: 'sessions#failure'
  get 'logout', to: 'sessions#destroy'

end
