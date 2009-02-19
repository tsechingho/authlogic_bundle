ENV['SCM'] = 'git' if yes?('Use git as scm? (y/n)')

def git?
  ENV['SCM'] == 'git'
end

plugin 'authlogic_bundle', :submodule => git?, 
  :git => 'git://github.com/tsechingho/authlogic_bundle.git'

load_template("vendor/plugins/authlogic_bundle/templates/git_init.rb") if git?
load_template("vendor/plugins/authlogic_bundle/templates/base.rb")