# Sets up the Rails environment for Cucumber
ENV["RAILS_ENV"] ||= "cucumber"
require File.expand_path(File.dirname(__FILE__) + '/../../../../../config/environment')
require 'cucumber/rails/world'

# Comment out the next line if you don't want Cucumber Unicode support
require 'cucumber/formatter/unicode'

# Comment out the next line if you don't want transactions to
# open/roll back around each scenario
Cucumber::Rails.use_transactional_fixtures

# Comment out the next line if you want Rails' own error handling
# (e.g. rescue_action_in_public / rescue_responses / rescue_from)
Cucumber::Rails.bypass_rescue

require 'webrat'
require 'cucumber/webrat/table_locator' # Lets you do table.diff!(table_at('#my_table').to_a)

Webrat.configure do |config|
  config.mode = :rails
end

require 'cucumber/rails/rspec'
require 'webrat/core/matchers'
require 'email_spec/cucumber'

# http://authlogic.rubyforge.org/classes/Authlogic/TestCase.html
require 'authlogic/test_case'
include Authlogic::TestCase
#setup :activate_authlogic

# http://www.tzi.org/~sbartsch/declarative_authorization/master/classes/Authorization/Maintenance.html
require 'declarative_authorization/maintenance'
include Authorization::Maintenance
