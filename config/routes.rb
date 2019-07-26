Rails.application.routes.draw do
  root to: "feeds#index"

  resources :feeds do
    resources :entries
    resources :skins
  end

  get '/refresh_news', to: 'feeds#refresh_news'
  get '/refresh_skins', to: 'feeds#refresh_skins'
  get '/publish_news', to: 'entries#publish'
  get '/publish_skins', to: 'skins#publish'

end
