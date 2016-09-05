# require 'resque_web'
Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get '/search/:id', to: 'search#search', as: :search

  get '/suggest/:id', to: 'suggest#suggest', as: :suggest

  get '/about', to: 'about#about', as: :about

  mount ResqueWeb::Engine => "/jobs"

end
