Rails.application.routes.draw do
  # root to: 'toppages#index'
  root to: 'topics#index'

  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  get 'signup', to: 'users#new'
  resources :users, only: [:index, :show, :new, :create] do
    member do
      get :followings
      get :followers
      get :favoritenows # favoritepostsの左部結合部のtypetalks
      get :post_users # favoritepostsの左部結合部のtypetalksから参照したusers
    end
    # 今は検索機能は使用しない
    # collection do
    #   get :search
    # end
  end

  resources :typetalks, only: [:create, :destroy]
  resources :relationships, only: [:create, :destroy]
  # 投稿のお気に入り機能
  resources :favoriteposts, only: [:create, :destroy]

  #typetalk用
  resources :topics, only: [:index, :show, :new, :create, :destroy]
end