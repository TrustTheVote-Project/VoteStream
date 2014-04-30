env = ENV['RACK_ENV'] || ENV['RAILS_ENV']
if env == 'production' || env == 'staging'
  Rake::TaskManager.class_eval do
    def remove_task(task_name)
      @tasks.delete(task_name.to_s)
    end
  end

  Rake.application.remove_task('db:structure:dump')
  namespace :db do
    namespace :structure do
      task :dump do
        # Overridden to do nothing
      end
    end
  end
end
