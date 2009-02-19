ENV['SCM'] = 'git' if yes?('Use git as scm? (y/n)')
scm = ENV['SCM'] ? 'git' : nil
submodule_token = (scm == 'git') ? true : false

plugin 'authlogic_bundle', :submodule => submodule_token, 
  :git => 'git://github.com/tsechingho/authlogic_bundle.git'
load_template("vendor/plugins/authlogic_bundle/templates/base.rb")