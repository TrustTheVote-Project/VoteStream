Enrs::Application.routes.draw do
  root 'pages#front'
  get  '/scoreboards'           => 'scoreboards#index', as: 'scoreboards'
  get  '/scoreboards/:locality' => 'scoreboards#show', as: 'scoreboard'

  get '/federal' => 'pages#federal', as: :federal
  get '/state' => 'pages#state'
  get '/other' => 'pages#state_with_color'

  namespace :admin do
    root 'states#index'

    resources :states
    resources :localities

    get  '/data' => 'data#index', as: 'data'
    post '/load_definitions' => 'data#load_definitions', as: 'load_definitions'
  end

  get '/data/districts' => 'data#districts'
  get '/data/precincts' => 'data#precincts'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
