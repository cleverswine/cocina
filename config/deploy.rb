set :application, 'cocina'
set :svn_dir, 'cocina187'
set :local_ssh_session_name, 'cs'
set :user, ''
set :domain, ''

set :deploy_to, "/home/#{user}/rails_apps/#{application}"
set :use_sudo, false
ssh_options[:port] = 7822
ssh_options[:forward_agent] = true
default_run_options[:pty] = true

set :bundle_flags,    "--deployment"    # --quiet
 
set :default_environment, {
  'GEM_HOME' => "/home/#{user}/ruby/gems",
  'GEM_PATH' => "/home/#{user}/ruby/gems:/usr/lib/ruby/gems/1.8",
  'PATH' => "/home/#{user}/ruby/gems/bin:$PATH"
}

set :scm, 'subversion'
#set :checkout, 'export'
set :repository,  "svn+a2hosting://#{user}@#{domain}/home/#{user}/svn/#{svn_dir}"
set :local_repository, "svn+ssh://#{user}@#{local_ssh_session_name}/home/#{user}/svn/#{svn_dir}"

server domain, :app, :web, :db, :primary => true

desc "Write current revision to app/layouts/_revision.rhtml"
task :publish_revision do
  #sed removes the 'M' from revision number
  run "svnversion #{deploy_to}/current/app | sed -e 's/M//' > #{deploy_to}/current/app/views/layouts/_revision.html.erb"
end

# run bundler
require 'bundler/capistrano' 

# make sure to install gems before trying to compile assets
before 'deploy:assets:precompile', 'bundle:install'

# clean up old releases on each deploy
after 'deploy:restart', 'deploy:cleanup'

# run db:migrate
after 'deploy:update_code', 'deploy:migrate'

#update revision number
before 'deploy:restart', 'publish_revision'

# app restart, for Passenger mod_rails
 namespace :deploy do
   task :start do ; end
   task :stop do ; end
   task :restart, :roles => :app, :except => { :no_release => true } do
     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
   end
end