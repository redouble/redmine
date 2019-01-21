#!/usr/bin/env puma

# start puma with:
# bundle exec puma -C ./config/puma.rb

shared_dir = './'

# daemonize true

# Min and Max threads per worker
threads 1, 1

# Default to production
rails_env = ENV['RAILS_ENV'] || "production"
environment rails_env

# Set up socket location
bind "tcp://0.0.0.0:8081"

# Logging
stdout_redirect "#{shared_dir}/log/puma.stdout.log", "#{shared_dir}/log/puma.stderr.log", true

# Set master PID and state locations
pidfile "#{shared_dir}/pids/puma.pid"
state_path "#{shared_dir}/pids/puma.state"
activate_control_app
#
on_worker_boot do
  require "active_record"
  ActiveRecord::Base.connection.disconnect! rescue ActiveRecord::ConnectionNotEstablished
  ActiveRecord::Base.establish_connection(YAML.load_file("#{shared_dir}/config/database.yml")[rails_env])
end
