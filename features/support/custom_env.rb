require 'email_spec'
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
