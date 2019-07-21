Rails.application.routes.draw do
  root to: "feeds#index"

  resources :feeds do
    resources :entries
  end

end
