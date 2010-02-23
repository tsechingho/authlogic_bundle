SOURCE = "vendor/plugins/authlogic_bundle" unless defined? SOURCE
load_template("#{SOURCE}/templates/helper.rb") unless self.respond_to? :file_inject

##############################
# RSpec
##############################
gem 'rspec', :lib => false, :version => '>= 1.3.0', :env => 'test'
gem 'rspec-rails', :lib => false, :version => '>= 1.3.2', :env => 'test'
gem 'remarkable', :lib => false, :version => '>=3.1.13', :env => 'test'
gem 'remarkable_activerecord', :lib => false, :version => '>=3.1.13', :env => 'test'
gem 'remarkable_rails', :lib => false, :version => '>=3.1.13', :env => 'test'
gem 'shoulda', :lib => false, :version => '>=2.10.3', :env => 'test' # thoughtbot
gem 'factory_girl', :lib => false, :version => '>=1.2.3', :env => 'test' # thoughtbot

rake 'gems:install', :sudo => true, :env => 'test'

generate :rspec

file 'spec/spec.opts', open("#{SOURCE}/spec/spec.opts").read

file_inject 'spec/spec_helper.rb', "require 'spec/rails'", <<-CODE
require 'remarkable_rails'
require 'shoulda'
require 'factory_girl'
CODE

##############################
# Cucumber
##############################
gem 'ruby-debug-base', :lib => false, :version => '>=0.10.3', :env => 'test'
gem 'ruby-debug', :lib => false, :version => '>=0.10.3', :env => 'test'
gem 'term-ansicolor', :lib => false, :version => '>=1.0.4', :env => 'test'
gem 'treetop', :lib => false, :version => '>=1.4.4', :env => 'test'
gem 'diff-lcs', :lib => false, :version => '>=1.1.2', :env => 'test'
gem 'nokogiri', :lib => false, :version => '>=1.4.1', :env => 'test'
gem 'builder', :lib => false, :version => '>=2.1.2', :env => 'test'
gem 'cucumber', :lib => false, :version => '>=0.6.2', :env => 'test'
gem 'cucumber-rails', :lib => false, :version => '>=0.2.4', :env => 'test'
gem 'database_cleaner', :lib => false, :version => '>=0.5.0', :env => 'test'
gem 'webrat', :lib => false, :version => '>=0.7.0', :env => 'test'
gem 'email_spec', :lib => 'email_spec', :version => '>=0.5.0', :env => 'test' # bmabey

# we still need 'test' environment to install cucumber related gems
rake 'gems:install', :sudo => true, :env => 'test'

generate :cucumber

gem 'email_spec', :lib => 'email_spec', :version => '>=0.5.0', :env => 'cucumber' # bmabey

file 'config/cucumber.yml', open("#{SOURCE}/config/cucumber.yml").read

file_append 'features/support/custom_env.rb', open("#{SOURCE}/features/support/custom_env.rb").read

generate :email_spec

file 'features/step_definitions/custom_email_steps.rb', <<-CODE
CODE

file_inject 'spec/spec_helper.rb', "require 'spec/rails'", <<-CODE
require 'email_spec/helpers'
require 'email_spec/matchers'
CODE

file_inject 'spec/spec_helper.rb', "Spec::Runner.configure do |config|", <<-CODE
  config.include(EmailSpec::Helpers)
  config.include(EmailSpec::Matchers)
CODE

##############################
# RCov & Autotest
##############################
gem 'rcov', :lib => 'rcov', :version => '>=0.9.7.1', :env => 'test' # relevance
gem 'ZenTest', :lib => 'autotest', :version => '>=4.2.1', :env => 'test'
gem 'autotest-notification', :lib => 'autotest_notification', :version => '>=2.1.0', :env => 'test' # carlosbrando

rake 'gems:install', :sudo => true, :env => 'test'

file 'spec/rcov.opts', <<-CODE
--exclude "spec/*,gems/*,features/*"
--rails
--aggregate "coverage.data"
CODE

run 'an-install'
#run 'an-uninstall'

file_append 'config/environments/test.rb', <<-CODE

ENV['AUTOFEATURE'] = "true"
ENV['RSPEC'] = "true"
CODE

##############################
# Misc
##############################
file_append 'features/support/env.rb', <<-CODE

# http://authlogic.rubyforge.org/classes/Authlogic/TestCase.html
require 'authlogic/test_case'
include Authlogic::TestCase
#setup :activate_authlogic

# http://www.tzi.org/~sbartsch/declarative_authorization/master/classes/Authorization/Maintenance.html
require 'declarative_authorization/maintenance'
include Authorization::Maintenance

CODE


if git?
  git :submodule => "init"
  git :submodule => "update"
  git :add => "config lib script spec features"
  git :commit => "-m 'setup testing suite'"
end