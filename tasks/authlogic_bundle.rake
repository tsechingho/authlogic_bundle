vendored_cucumber_dir = Dir["#{RAILS_ROOT}/vendor/{gems,plugins}/cucumber*"].first
vendored_cucumber_bin = "#{vendored_cucumber_dir}/bin/cucumber" unless vendored_cucumber_dir.nil?
$LOAD_PATH.unshift("#{vendored_cucumber_dir}/lib") unless vendored_cucumber_dir.nil?

namespace :authlogic_bundle do
  plugin_path = "vendor/plugins/authlogic_bundle"

  desc "Sync bundled files"
  task :sync do
    system "rsync -rbv #{plugin_path}/app/helpers/application_helper.rb app/helpers"
    system "rsync -rbv #{plugin_path}/app/helpers/layout_helper.rb app/helpers"
    system "rsync -ruv #{plugin_path}/config/authorization_rules.rb config"
    system "rsync -ruv #{plugin_path}/config/cucumber.yml config"
    system "rsync -ruv #{plugin_path}/config/environments config"
    system "rsync -ruv #{plugin_path}/config/initializers config"
    system "rsync -ruv #{plugin_path}/config/locales config"
    system "rsync -ruv #{plugin_path}/config/notifier.yml config"
    system "rsync -ruv #{plugin_path}/features/support/custom_env.rb features/support/"
    # system "rsync -ruv #{plugin_path}/public ."
  end

  begin
    require 'cucumber/rake/task'

    Cucumber::Rake::Task.new({:features => 'db:test:prepare'}, "Run Features of authlogic_bundle with Cucumber") do |t|
      t.binary = vendored_cucumber_bin # If nil, the gem's binary is used.
      t.fork = true # You may get faster startup if you set this to false
      t.cucumber_opts = "--color --tags ~@wip --strict --format #{ENV['CUCUMBER_FORMAT'] || 'pretty'} #{plugin_path}/features"
      # t.profile = "authlogic_bundle"
    end
  rescue LoadError
    desc 'Cucumber rake task not available'
    task :features do
      abort 'Cucumber rake task is not available. Be sure to install cucumber as a gem or plugin'
    end
  end
end
