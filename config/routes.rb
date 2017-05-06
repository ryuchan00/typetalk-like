Rails.application.routes.draw do
  # root to: 'toppages#index'
  root to: 'topics#index'

  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  get 'signup', to: 'users#new'

  get 'receive', to: 'topics#receive'
  post 'receive', to: 'topics#receive'

  get 'topic_all', to: 'topics#all'
  get 'topics/all_post', to: 'topics#all_post'
  get 'topic_user', to: 'topics#user'
  get 'past_post', to: 'topics#past_post'
  post 'past_post', to: 'topics#past_post'
  post 'all_process', to: 'topics#all_process'
  get 'update_latest', to: 'topics#update_latest'

  resources :users, only: [:index, :show, :new, :create] do
    # member do
    #   get :followings
    #   get :followers
    #   get :favoritenows # favoritepostsの左部結合部のtypetalks
    #   get :post_users # favoritepostsの左部結合部のtypetalksから参照したusers
    # end
    # 今は検索機能は使用しない
    # collection do
    #   get :searc　
    # end
  end

  # resources :typetalks, only: [:create, :destroy]
  # resources :relationships, only: [:create, :destroy]
  # 投稿のお気に入り機能
  # resources :favoriteposts, only: [:create, :destroy]

  #typetalk用
  resources :topics, only: [:index, :show, :new, :create, :destroy]
end