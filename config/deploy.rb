#Use `cap my_stage TASK` such as `cap production deploy`
set :stages, %w(production staging)
set :default_stage, "staging"

require 'capistrano/ext/multistage'

set :application, "expertiza"
set :scm, :git
set :repository,  "git://github.com/expertiza/expertiza.git"
set :user, "rails"
set :group, "rails"
set :use_sudo, false
set :runner, "www-data"

namespace :deploy do
  task :stop do; end
  task :start do; end

  desc "Restart the application."
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end

  desc "Symlink shared files into the current deploy directory."
  task :symlink_shared do
    run "ln -s #{shared_path}/pg_data #{release_path}"
    run "ln -sf #{shared_path}/database.yml #{release_path}/config/database.yml"
  end
end

after "deploy:update_code", "deploy:symlink_shared"

desc "Load production data into the local development database."
task :load_production_data, :roles => :db, :only => { :primary => true } do
  require 'yaml'
 
  database = YAML::load_file('config/database.yml')
  filename = "dump.#{Time.now.strftime '%Y-%m-%d_%H:%M:%S'}.sql.gz"
 
  on_rollback { delete "/tmp/#{filename}" }
  run "mysqldump -u #{database['production']['username']} #{database['production']['database']} --add-drop-table | gzip > /tmp/#{filename}" do |channel, stream, data|
    puts data
  end

  on_rollback { system " rm -f #{filename}" }
  get "/tmp/#{filename}", filename

  logger.info 'Dropping and recreating database'
  system 'rake db:drop && rake db:create'

  logger.info 'Importing production database into local development database'
  system "gunzip -c #{filename} | mysql -u #{database['development']['username']} --password=#{database['development']['password']} #{database['development']['database']} && rm -f #{filename}"
end

set :default_environment, 'JAVA_HOME' => "/etc/alternatives/java_sdk/"
# set :default_environment, 'JAVA_HOME' => "/usr/lib/jvm/java-6-openjdk/"
