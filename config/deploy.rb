set :application, 'votestream'
set :repo_url, 'git@github.com:TrustTheVote-Project/VoteStream.git'

set :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

set :deploy_to, "/var/www/votestream"
set :scm, :git

set :format, :pretty
set :log_level, :debug
set :pty, true

SSHKit.config.command_map[:rake] = "bundle exec rake"

set :linked_files, %w{config/database.yml}
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# set :default_env, { path: "/opt/ruby/bin:$PATH" }
set :keep_releases, 5

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  after :finishing, 'deploy:cleanup'
end

namespace :db do
  task :seed do
    on roles(:app) do
      execute "cd #{current_path} && RAILS_ENV=#{fetch(:rails_env)} bundle exec rake db:seed"
    end
  end
end
