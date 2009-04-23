SOURCE = "vendor/plugins/authlogic_bundle"
load_template("#{SOURCE}/templates/helper.rb")

##############################
# Cucumber
##############################
gem 'term-ansicolor', :lib => 'term/ansicolor', :version => '>=1.0.3', :env => 'test'
gem 'treetop', :lib => 'treetop', :version => '>=1.2.5', :env => 'test'
gem 'diff-lcs', :lib => 'diff/lcs', :version => '>=1.1.2', :env => 'test'
gem 'nokogiri', :lib => 'nokogiri', :version => '>=1.2.3', :env => 'test'
gem 'builder', :lib => 'builder', :version => '>=2.1.2', :env => 'test'
gem 'cucumber', :lib => 'cucumber', :version => '>=0.3.0', :env => 'test'

generate :cucumber

##############################
# Webrat
##############################
gem 'webrat', :lib => 'webrat', :version => '>=0.4.4', :env => 'test'

##############################
# RSpec
##############################
gem 'rspec', :lib => 'spec', :version => '>= 1.2.4', :env => 'test'
gem 'rspec-rails', :lib => 'spec/rails', :version => '>= 1.2.4', :env => 'test'
# plugin 'rspec-rails', :submodule => git?,
#   :git => 'git://github.com/dchelimsky/rspec-rails.git'
# plugin 'rspec', :submodule => git?,
#   :git => 'git://github.com/dchelimsky/rspec.git'
generate :rspec

file_append 'spec.opts', <<-CODE
--colour
--format progress
--format html:coverage/spec.html
--loadby mtime
--reverse
CODE

gem 'thoughtbot-factory_girl', :lib => 'factory_girl',
  :source => 'http://gems.github.com', :env => 'test'
# plugin 'factory_girl', :submodule => git?,
#   :git => 'git://github.com/thoughtbot/factory_girl.git'

# plugin 'shoulda', :submodule => git?,
#   :git => 'git://github.com/thoughtbot/shoulda.git'

##############################
# RCov
##############################
gem 'spicycode-rcov', :lib => 'rcov', :version => '>=0.4.4',
  :source => 'http://gems.github.com', :env => 'test'

#rakefile 'rcov.rake', open("#{SOURCE}/tasks/rcov.rake").read

file_append 'rcov.opts', <<-CODE
--exclude "spec/*,gems/*,features/*"
--rails
--aggregate "coverage.data"
CODE

##############################
# Autotest
##############################
gem 'ZenTest', :lib => 'zentest', :version => '>=4.0.0', :env => 'test'
gem 'carlosbrando-autotest-notification', :lib => 'autotest_notification', :version => '>=1.9.1',
  :source => 'http://gems.github.com', :env => 'test'
run 'an-install'
#run 'an-uninstall'

file_append 'config/environments/test.rb', <<-CODE
ENV['AUTOFEATURE'] = "true"
ENV['RSPEC'] = "true"
CODE


rake 'gems:install', :sudo => true, :env => 'test'

if git?
  git :submodule => "init"
  git :submodule => "update"
  git :commit => "-m 'setup testing suit'"
end