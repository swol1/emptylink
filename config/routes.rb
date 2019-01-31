Rails.application.routes.draw do
  devise_for :users
  resources :users, only: :show

  resources :links

  root to: 'pages#main'
  get '*short_url', to: 'links#open', as: :shortlink
end
