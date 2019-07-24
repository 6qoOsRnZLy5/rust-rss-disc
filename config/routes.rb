Rails.application.routes.draw do
  root to: "feeds#index"

  resources :feeds do
    resources :entries
  end

  get '/refresh', to: 'feeds#refresh'
  get '/publish', to: 'entries#publish'

end
