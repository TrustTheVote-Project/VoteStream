Enrs::Application.routes.draw do
  root 'pages#front'

  get  '/scoreboards'           => 'scoreboards#index', as: 'scoreboards'
  get  '/scoreboards/:locality' => 'scoreboards#show',  as: 'scoreboard'

  namespace :admin do
    root 'states#index'

    resources :states
    resources :localities

    get  '/data' => 'data#index', as: 'data'
    post '/load_definitions' => 'data#load_definitions', as: 'load_definitions'
    post '/load_nist' => 'data#load_nist', as: 'load_nist'
    post '/load_nist_results' => 'data#load_nist_results', as: 'load_nist_results'
    post '/load_demographics' => 'data#load_demographics', as: 'load_demographics'
    post '/load_results' => 'data#load_results', as: 'load_results'
    get  '/full_reset' => 'data#full_reset', as: 'full_reset'
  end

  get  '/data/localities/:locality_id/districts'        => 'data#districts'
  post '/data/districts'        => 'data#districts'
  get  '/data/localities/:locality_id/precincts'        => 'data#precincts'
  get  '/data/localities/:locality_id/counties'        => 'data#counties'
  #post '/data/precincts'        => 'data#precincts'
  get  '/data/voting_results'   => 'data#voting_results'
  post '/data/voting_results'   => 'data#voting_results'
  get  '/data/localities/:locality_id/all_refcons'      => 'data#all_refcons'
  #post '/data/all_refcons'      => 'data#all_refcons'
  #get  '/data/region_refcons'   => 'data#region_refcons'
  post '/data/localities/:locality_id/region_refcons'   => 'data#region_refcons'
  get  '/data/precinct_results' => 'data#precinct_results'
  post '/data/precinct_results' => 'data#precinct_results'
  get  '/data/precinct_colors'  => 'data#precinct_colors'
  post '/data/precinct_colors'  => 'data#precinct_colors'
  get  '/data/election_metadata'   => 'data#election_metadata'
  post '/data/election_metadata'   => 'data#election_metadata'

  get '/feed(.:format)'        => 'api/v1#filtered_election_feed', as: 'feed'
  get '/feed-nist(.:format)'        => 'api/v1#nist_election_feed', as: 'nist_feed'

  # API
  namespace :resources, module: 'api' do
    namespace :v1, module: nil, format: 'json' do
      get '/elections'                 => 'v1#elections'
      get '/election_districts'        => 'v1#election_districts'
      get '/election_localities'       => 'v1#election_localities'
      get '/election_ballot_style'     => 'v1#election_ballot_style'
      get '/election_contests'         => 'v1#election_contests'
      get '/election_referenda'        => 'v1#election_referenda'
      get '/election_results_precinct' => 'v1#election_results_precinct'
      get '/election_results_locality' => 'v1#election_results_locality'
    end

    namespace :v1, module: nil, format: 'xml' do
      get '/election_feed'             => 'v1#election_feed'
    end

    namespace :v1, module: nil do
      get '/election_feed_status'      => 'v1#election_feed_status'
      get '/election_feed_seq'         => 'v1#election_feed_seq'
    end
  end
end
