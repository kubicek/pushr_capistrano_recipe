# usual capistrano variables
set :application "my_application"
set :deploy_to, "/home/deployer/app"

# put the folowing code into your deploy.rb
namespace :pushr do
  set :pushr_path, "#{deploy_to}/pushr"

  desc "Install pushr"
  task :install do
    run "git clone git://github.com/karmi/pushr.git #{pushr_path}"
  end

  desc "Update pushr"
  task :update do
    run "cd #{pushr_path}; git pull origin master"
  end
  
  task :check do
    run "cd #{pushr_path}; rake app:check"
  end
    
  desc "Create config.yml"
  task :configure do
    set :http_auth_username, Capistrano::CLI.ui.ask("Enter new user name for http access: ")
    set :http_auth_password, Capistrano::CLI.password_prompt("Enter new password for http access: ")
    set :twitter_username, Capistrano::CLI.ui.ask("Your twitter username: ")
    set :twitter_password, Capistrano::CLI.password_prompt("Enter twitter password: ")
    pushr_configuration =<<-EOF
application: #{application}

# Username/password for HTTP Auth
username: #{http_auth_username}
password: #{http_auth_password}

# Full path to your Rails application, eg. "/var/www/my_rails_app"
path: #{deploy_to}

twitter:
  username: '#{twitter_username}'
  password: '#{twitter_password}' 
EOF
    put pushr_configuration, "#{pushr_path}/config.yml"
  end
  
  desc "Start pushr"
  task :start do
    run "cd #{pushr_path}; rake start"
  end
  
  desc "Stop pushr"
  task :stop do
    run "cd #{pushr_path}; rake stop"
  end

  desc "Restart pushr"
  task :restart do
    stop
    start
  end
  
  namespace :ssh do
    desc "Generate ssh key"
    task :generate_key do
      run "ssh-keygen -t rsa -f ~/.ssh/id_rsa -N ''"
    end
  
    desc "Authorize local key for accessing the same server"
    task :authorize_key do
      run "cd #{pushr_path}; rake app:add_public_key_to_localhost"
    end
    
    desc "Display public ssh key"
    task :get_public_key do
      run "cat ~/.ssh/id_rsa.pub"
    end
  end

end
