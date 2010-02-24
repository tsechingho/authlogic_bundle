LOCAL_SOURCE = template.sub('/templates/local.rb','')
SOURCE = "vendor/plugins/authlogic_bundle"

load_template("#{LOCAL_SOURCE}/templates/helper.rb")

load_template("#{LOCAL_SOURCE}/templates/git_init.rb") if git?

run "ln -s #{ENV['EDGE_RAILS']} vendor/rails" if edge_rails?

run "ln -s #{LOCAL_SOURCE} #{SOURCE}"

load_template("#{SOURCE}/templates/base.rb")

if yes?("Do you want to include bundled testing suit? (y/n)")
  load_template("#{SOURCE}/templates/testing.rb")
end

if yes?("Do you want to include bundled monitor suit? (y/n)")
  load_template("#{SOURCE}/templates/monitor.rb")
end
