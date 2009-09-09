SOURCE = "vendor/plugins/authlogic_bundle"
load_template("#{SOURCE}/templates/helper.rb")

#########################
#  Gems & Plugins
#########################

rake 'db:sessions:create'
file_append 'config/initializers/session_store.rb', <<-CODE
ActionController::Base.session_store = :active_record_store
CODE

# please note the order of config.gem and databse migration

gem 'stffn-declarative_authorization', :lib => 'declarative_authorization',
  :version => '>=0.3.2.2', :source => 'http://gems.github.com'
gem 'ruby-openid', :lib => 'openid', :version => '>=2.1.7'
gem 'authlogic-oid', :lib => 'authlogic_openid', :version => '>=1.0.4'
gem 'authlogic', :version => '>=2.1.1'
gem 'bcrypt-ruby', :lib => 'bcrypt', :version => '>=2.1.1'

rake 'gems:install', :sudo => true

# plugin 'authlogic', :submodule => git?, 
#   :git => 'git://github.com/binarylogic/authlogic.git'

# plugin 'declarative_authorization', :submodule => git?,
#   :git => 'git://github.com/stffn/declarative_authorization.git'

plugin 'open_id_authentication', :submodule => git?, 
  :git => 'git://github.com/rails/open_id_authentication.git'
plugin 'ssl_requirement', :submodule => git?,
  :git => 'git://github.com/rails/ssl_requirement.git'
plugin 'i18n_label', :submodule => git?,
  :git => 'git://github.com/iain/i18n_label.git'

generate :migration, 'create_users'
file Dir.glob('db/migrate/*_create_users.rb').first,
  open("#{SOURCE}/db/migrate/create_users.rb").read

generate :migration, 'add_open_id_to_users'
file Dir.glob('db/migrate/*_add_open_id_to_users.rb').first,
  open("#{SOURCE}/db/migrate/add_open_id_to_users.rb").read
rake 'open_id_authentication:db:create'

generate :migration, 'create_roles'
file Dir.glob('db/migrate/*_create_roles.rb').first,
  open("#{SOURCE}/db/migrate/create_roles.rb").read

generate :migration, 'create_preferences'
file Dir.glob('db/migrate/*_create_preferences.rb').first,
  open("#{SOURCE}/db/migrate/create_preferences.rb").read

rake 'db:migrate'#, :env => 'development'

#########################
#  Configuration
#########################
route "map.root :controller => 'home', :action => 'index'"
route "map.resources :users"
route "map.resources :roles"

file_append 'config/locales/en.yml', open("#{SOURCE}/config/locales/en.yml").read
file_append 'config/locales/zh-CN.yml', open("#{SOURCE}/config/locales/zh-CN.yml").read
file_append 'config/locales/zh-TW.yml', open("#{SOURCE}/config/locales/zh-TW.yml").read

run 'mkdir config/locales/rails'
file_append 'config/locales/rails/zh-CN.yml', open("#{SOURCE}/config/locales/rails/zh-CN.yml").read
file_append 'config/locales/rails/zh-TW.yml', open("#{SOURCE}/config/locales/rails/zh-TW.yml").read

run 'mkdir config/locales/authlogic'
file_append 'config/locales/authlogic/en.yml', open("#{SOURCE}/config/locales/authlogic/en.yml").read
file_append 'config/locales/authlogic/zh-CN.yml', open("#{SOURCE}/config/locales/authlogic/zh-CN.yml").read
file_append 'config/locales/authlogic/zh-TW.yml', open("#{SOURCE}/config/locales/authlogic/zh-TW.yml").read

run 'mkdir config/locales/authlogic_bundle'
file_append 'config/locales/authlogic_bundle/en.yml', open("#{SOURCE}/config/locales/authlogic_bundle/en.yml").read
file_append 'config/locales/authlogic_bundle/zh-CN.yml', open("#{SOURCE}/config/locales/authlogic_bundle/zh-CN.yml").read
file_append 'config/locales/authlogic_bundle/zh-TW.yml', open("#{SOURCE}/config/locales/authlogic_bundle/zh-TW.yml").read

file_append 'config/authorization_rules.rb', open("#{SOURCE}/config/authorization_rules.rb").read
file_append 'db/seeds.rb', open("#{SOURCE}/db/seeds.rb").read
rake 'db:seed' if Rails::VERSION::STRING >= "2.3.4"

file_append 'config/notifier.yml', open("#{SOURCE}/config/notifier.yml").read

# initializer 'config_loader.rb'
file_append 'config/initializers/config_loader.rb', open("#{SOURCE}/config/initializers/config_loader.rb").read

# initializer 'locales.rb'
file_append 'config/initializers/locales.rb', open("#{SOURCE}/config/initializers/locales.rb").read

#########################
#  MVC
#########################

# Controllers
file_inject 'app/controllers/application_controller.rb',
  'class ApplicationController < ActionController::Base', <<-CODE
  include AuthlogicBundle::Authentication
  include AuthlogicBundle::Authorization
  include AuthlogicBundle::Localization
  include SslRequirement

  def ssl_required?
    return ENV['SSL'] == 'on' ? true : false if defined? ENV['SSL']
    return false if local_request?
    return false if RAILS_ENV == 'test'
    super
  end
CODE

# Helpers
# NOTE: Only controller's helper in engines will be loaded.
file_inject 'app/helpers/application_helper.rb', 'module ApplicationHelper', <<-CODE
  def secure_mail_to(email, name = nil)
    return name if email.blank?
    mail_to email, name, :encode => 'javascript'
  end

  def at(klass, attribute, options = {})
    klass.human_attribute_name(attribute.to_s, options = {})
  end

  def openid_link
    link_to at(User, :openid_identifier), "http://openid.net/"
  end
CODE

file_append 'app/helpers/layout_helper.rb', open("#{SOURCE}/app/helpers/layout_helper.rb").read

if git?
  git :rm => "public/index.html"
  git :submodule => "init"
  git :submodule => "update"
  git :add => "app config db"
  git :commit => "-m 'install authlogic bundle'"
else
  run 'rm public/index.html'
end