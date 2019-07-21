Rails.application.routes.draw do
  root to: "feeds#index"

  resources :feeds do
    collection do
      get 'refresh'
    end
    resources :entries
  end

end
