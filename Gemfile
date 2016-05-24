source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.1'

# Use postgresql as the database for Active Record
gem 'pg'
gem 'activerecord-postgis-adapter'
gem 'activerecord-import'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'
gem 'compass-rails'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'haml-rails'
gem 'eco'
gem 'gon'
gem 'nokogiri'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'
gem 'csv_builder'
gem 'wkhtmltopdf-binary'
gem 'wicked_pdf'

gem "therubyracer"
#gem "less-rails" #Sprockets (what Rails 3.1 uses for its asset pipeline) supports LESS
gem "twitter-bootstrap-rails"

gem 'bootstrap3-rails'

# User VSSC parser libary to load VSSC files
# gem "vssc-ruby", :git=>"https://github.com/amekelburg/vssc_ruby.git"

# Use VEDaSpace to load NIST ERR files
gem "vedaspace", "1.3.8", :git=>"https://github.com/TrustTheVote-Project/VEDaSpace", :branch=>'master'

gem "oj" # For faster version of  to_json methods

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.1.2'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
group :development do
  gem 'capistrano', '~> 3.0.0'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'quiet_assets'
  gem 'better_errors'
  gem 'binding_of_caller'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
end

group :test do
  gem 'guard-rspec'
  gem 'shoulda-matchers'
  gem 'database_cleaner'
end

group :test, :development do
  gem 'factory_girl_rails'
  gem 'rspec-rails'
end

group :production do
  gem 'redis-rails'
end

# Use debugger
# gem 'debugger', group: [:development, :test]