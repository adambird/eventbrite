Rails.application.routes.draw do

  root 'main#index'
  get '/auth/:provider/callback', to: 'sessions#create'

end
