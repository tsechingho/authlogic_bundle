SOURCE = "vendor/plugins/authlogic_bundle" unless defined? SOURCE
load_template("#{SOURCE}/templates/helper.rb") unless self.respond_to? :file_inject

#########################
#  Gems & Plugins
#########################

rake 'db:sessions:create'
file_append 'config/initializers/session_store.rb', <<-CODE
ActionController::Base.session_store = :active_record_store
CODE

# please note the order of config.gem and databse migration
gem 'validation_reflection', :lib => 'validation_reflection', :version => '>= 0.3.6'
gem 'formtastic', :lib => 'formtastic', :version => '>= 0.9.7' # justinfrench
gem 'preferences', :lib => 'preferences', :version => '>= 0.3.1' # pluginaweek
gem 'declarative_authorization', :lib => 'declarative_authorization', :version => '>=0.4.1' # stffn
gem 'ruby-openid', :lib => 'openid', :version => '>=2.1.7'
gem 'rack-openid', :lib => 'rack/openid', :version => '>=1.0.1'
gem 'authlogic-oid', :lib => 'authlogic_openid', :version => '>=1.0.4'
gem 'authlogic', :version => '>=2.1.3' # binarylogic
gem 'bcrypt-ruby', :lib => 'bcrypt', :version => '>=2.1.2'

rake 'gems:install', :sudo => sudo?

plugin 'open_id_authentication', :submodule => git?, 
  :git => 'git://github.com/rails/open_id_authentication.git'
plugin 'ssl_requirement', :submodule => git?,
  :git => 'git://github.com/rails/ssl_requirement.git'

generate :formtastic

file_inject 'config/initializers/formtastic.rb',
  '# Formtastic::SemanticFormBuilder.all_fields_required_by_default = true', <<-CODE
Formtastic::SemanticFormBuilder.all_fields_required_by_default = false
CODE

file_inject 'config/initializers/formtastic.rb',
  '# Formtastic::SemanticFormBuilder.i18n_lookups_by_default = false', <<-CODE
Formtastic::SemanticFormBuilder.i18n_lookups_by_default = true
CODE

file_append 'public/stylesheets/formtastic_changes.css', <<-CODE
form.formtastic fieldset { border: 1px solid rgb(204, 204, 204); margin: 0 0 1.5em 0; padding: 1.4em; -webkit-border-radius: 15px; -moz-border-radius: 15px; border-radius: 15px; }
CODE

generate :migration, 'create_users'
file Dir.glob('db/migrate/*_create_users.rb').first,
  open("#{SOURCE}/db/migrate/create_users.rb").read

# since master branch of open_id_authentication use rack-openid and use memory store instead of db store,
# authlogic-oid do not follow up yet and will fail openid authentication.
# Let's roll back to old commit to make things easier.
# I'll check rack version of open_id_authentication later.
if git?
  inside('vendor/plugins/open_id_authentication') do
    run "git reset --hard 079b91f70602814c98d4345e198f743bb56b76b5"
  end
  git :add => 'vendor/plugins/open_id_authentication'
end

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
    return false if Rails.env == 'test'
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

  def attr_translate(klass, attribute = nil, options = {})
    return klass.human_name(options) if attribute.blank?
    klass.human_attribute_name(attribute.to_s, options)
  end
  alias :at :attr_translate

  def flash_translate(key, options = {})
    I18n.t(key, :scope => [controller_name, action_name, :flash])
    I18n.t(key, {:scope => [controller_name, action_name, :flash]}.merge(options))
  end
  alias :ft :flash_translate

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
