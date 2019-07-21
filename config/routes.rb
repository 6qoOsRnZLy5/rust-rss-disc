Rails.application.routes.draw do
  root to: "feeds#index"

  resources :feeds do
    get 'refresh'
    resources :entries
  end

end
