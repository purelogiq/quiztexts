# config valid only for current version of Capistrano
lock '3.6.1'

set :application, 'flashtxts'
set :repo_url, 'https://github.com/purelogiq/flashtxts.git'

def abort_deploy
  puts 'Aborting deploy'
  exit
end

ask :confirmation, "\n > You are about to deploy to flashtxts.com. Are you sure you want to do that? (yes/no)"
abort_deploy unless fetch(:confirmation) == 'yes'
ask :confirmation, "\n > Have you posted in the 67-475Go! Slack builds channel that you are deploying? (yes/no)"
abort_deploy unless fetch(:confirmation) == 'yes'
ask :confirmation, "\n > Are you sure you want to deploy the **#{`git rev-parse --abbrev-ref HEAD`.chomp}** branch that you are currently on? (yes/no)"
abort_deploy unless fetch(:confirmation) == 'yes'
ask :confirmation, "\n > The deploy pulls directly from GitHub, not your machine. Have you pushed all your changes to GitHub? (yes/no)"
abort_deploy unless fetch(:confirmation) == 'yes'
ask :confirmation, "\n > Are you ready to do this?!!??!! (yes or yes)"
abort_deploy unless fetch(:confirmation) == 'yes'
set :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/flashtxts'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: 'log/capistrano.log', color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is [] (They let you replace the app files with server files)
# append :linked_files, 'config/database.yml', 'config/secrets.yml'
set :linked_files, fetch(:linked_files, []).push('config/puma.rb', '.env.production')

# Default value for linked_dirs is []
# append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system'
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system', 'public/uploads')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Puma:
set :puma_conf, "#{shared_path}/config/puma.rb"

task :puts_all_done do
  puts "All done! Go to http://flashtxts.com to try it out."
end

namespace :deploy do
  before 'check:linked_files', 'puma:config'
  before 'check:linked_files', 'puma:nginx_config'
  after 'puma:smart_restart', 'nginx:restart'
  after 'nginx:restart', :puts_all_done
end