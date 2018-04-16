# require 'resque_web'
Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: 'about#about'

  get '/search/:id', to: 'search#search', as: :search

  get '/suggest/:id', to: 'suggest#suggest', as: :suggest

  get '/about', to: 'about#about', as: :about

  post '/api/ocr_resource'

  mount ResqueWeb::Engine => "/jobs"

end
