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
    post '/load_results' => 'data#load_results', as: 'load_results'
    get  '/full_reset' => 'data#full_reset', as: 'full_reset'
  end

  get '/data/districts' => 'data#districts'
  get '/data/precincts' => 'data#precincts'
  get '/data/precincts_geometries' => 'data#precincts_geometries'
  get '/data/voting_results' => 'data#voting_results'
  get '/data/all_refcons' => 'data#all_refcons'
  get '/data/region_refcons' => 'data#region_refcons'
  get '/data/precinct_results' => 'data#precinct_results'

  # API
  namespace :resources, module: 'api' do
    namespace :v1, module: nil, format: 'json' do
      get '/elections'             => 'v1#elections'
      get '/election_districts'    => 'v1#election_districts'
      get '/election_localities'   => 'v1#election_localities'
      get '/election_ballot_style' => 'v1#election_ballot_style'
      get '/election_contests'     => 'v1#election_contests'
      get '/election_referenda'    => 'v1#election_referenda'
    end
  end

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
