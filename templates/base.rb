SOURCE = "vendor/plugins/authlogic_bundle"
load_template("#{SOURCE}/templates/helper.rb")

#########################
#  Gems & Plugins
#########################

rake 'db:sessions:create'
file_append 'config/initializers/session_store.rb', <<-CODE
ActionController::Base.session_store = :active_record_store
CODE

gem 'bcrypt-ruby', :lib => 'bcrypt', :version => '>=2.0.3'
gem 'authlogic', :version => '>=1.4.1'
# plugin 'authlogic', :submodule => git?, 
#   :git => 'git://github.com/binarylogic/authlogic.git'
generate :migration, 'create_users'
file Dir.glob('db/migrate/*_create_users.rb').first,
  open("#{SOURCE}/db/migrate/create_users.rb").read

gem 'ruby-openid', :lib => 'openid', :version => '>=2.1.4'
plugin 'open_id_authentication', :submodule => git?, 
  :git => 'git://github.com/rails/open_id_authentication.git'
generate :migration, 'add_open_id_to_users'
file Dir.glob('db/migrate/*_add_open_id_to_users.rb').first,
  open("#{SOURCE}/db/migrate/add_open_id_to_users.rb").read
rake 'open_id_authentication:db:create'

plugin 'declarative_authorization', :submodule => git?, 
  :git => 'git://github.com/stffn/declarative_authorization.git'
generate :migration, 'create_roles'
file Dir.glob('db/migrate/*_create_roles.rb').first,
  open("#{SOURCE}/db/migrate/create_roles.rb").read

rake 'gems:install', :sudo => true
rake 'db:migrate'#, :env => 'development'

#########################
#  Configuration
#########################
route "map.root :controller => 'home', :action => 'index'"
route "map.resources :users"
route "map.resources :roles"

run "cp #{SOURCE}/config/authorization_rules.rb config"
run "cp #{SOURCE}/config/locales/* config/locales"

file 'config/notifier.yml', <<-CODE
development:
  notifier:
    host: localhost:3000
    name: User Notifier
    email: noreply@example.com

test:
  notifier:
    host: www.example.com
    name: User Notifier
    email: noreply@example.com

production:
  notifier:
    host: www.example.com
    name: User Notifier
    email: noreply@example.com

CODE

# initializer 'config_loader.rb'
file_append 'config/initializers/config_loader.rb', <<-CODE
config = File.read(Rails.root.join('config', 'notifier.yml'))
NOTIFIER = YAML.load(config)[RAILS_ENV]['notifier'].symbolize_keys
CODE

# fixed in rails edge
# initializer 'rails_patch.rb'
file_append 'config/initializers/rails_patch.rb', <<-CODE
# This is a hack for rails 2.3.0, and fixed in rails edge
# http://rails.lighthouseapp.com:80/projects/8994/tickets/1970-app-routesrb-not-loaded-when-both-engine-and-inflections-present
class Rails::Initializer
  def initialize_routing
    return unless configuration.frameworks.include?(:action_controller)

    ActionController::Routing.controller_paths += configuration.controller_paths
    ActionController::Routing::Routes.add_configuration_file(configuration.routes_configuration_file)
    ActionController::Routing::Routes.reload!
  end
end
CODE

#########################
#  MVC
#########################

# Controllers
file_inject 'app/controllers/application_controller.rb',
  'class ApplicationController < ActionController::Base', <<-CODE
  include AuthenticatedSystem
  include AuthorizedSystem
  include LocalizedSystem
CODE

# fixed in rails edge
run "cp -R #{SOURCE}/app/views/user_mailer app/views"
run "cp #{SOURCE}/app/helpers/*_helper.rb app/helpers"

if git?
  git :rm => "public/index.html"
  git :submodule => "init"
  git :submodule => "update"
  git :add => "app config db"
  git :commit => "-m 'install authlogic bundle'"
else
  run 'rm public/index.html'
end