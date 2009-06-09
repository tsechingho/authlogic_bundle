ENV['SCM'] = 'git' if yes?('Use git as scm? (y/n)')

def git?
  ENV['SCM'] == 'git'
end

load_template("http://github.com/tsechingho/authlogic_bundle/raw/master/templates/git_init.rb") if git?

rails_edge_path = ask("If you want to symbol link rails edge, please give absolute path or press enter to skip:")
run "ln -s #{rails_edge_path} vendor/rails" unless rails_edge_path.blank?

plugin 'authlogic_bundle', :submodule => git?, 
  :git => 'git://github.com/tsechingho/authlogic_bundle.git'

load_template("vendor/plugins/authlogic_bundle/templates/base.rb")

load_template("vendor/plugins/authlogic_bundle/templates/testing.rb") if yes?("Do you want to include bundled testing suit? (y/n)")

load_template("vendor/plugins/authlogic_bundle/templates/monitor.rb") if yes?("Do you want to include bundled monitor suit? (y/n)")
