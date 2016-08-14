Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get '/search/:id', to: 'search#search', as: 'search'

  # FIXME: Autocomplete is a dummy route right now that just returns 200 OK
  #        so that UV works.
  get '/autocomplete/:id', to: proc {[200, {}, ['']]}
  # get '/autocomplete/:id', to: 'search#autocomplete', as: 'autocomplete'

end
