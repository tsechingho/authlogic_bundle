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
require 'cucumber/webrat/element_locator' # Lets you do table.diff!(element_at('#my_table_or_dl_or_ul_or_ol').to_table)

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

# mock the response of open id server
require 'authlogic_bundle/test_case/open_id_authentication_helper'
# add session helper
require 'authlogic_bundle/test_case/session_helper'

# It is recommended that you should only mock and stub things 
# like Time and external services like OpenID etc.

# Comment out the following lines if you want to use RSpec mock.
# require "spec/mocks"
#
# Before do
#   $rspec_mocks ||= Spec::Mocks::Space.new
# end
#
# After do
#   begin
#     $rspec_mocks.verify_all
#   ensure
#     $rspec_mocks.reset_all
#   end
# end

# Comment out the following lines if you want to use Mocha.
# require "mocha"
#
# World(Mocha::Standalone)
#
# Before do
#   mocha_setup
# end
#
# After do
#   begin
#     mocha_verify
#   ensure
#     mocha_teardown
#   end
# end
