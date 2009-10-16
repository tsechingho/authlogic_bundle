['/vendor/plugins/cucumber/lib'].each do |lib_path|
  $LOAD_PATH.unshift(RAILS_ROOT + lib_path) if File.directory?(RAILS_ROOT + lib_path)
end

namespace :authlogic_bundle do
  plugin_path = "vendor/plugins/authlogic_bundle"

  desc "Sync bundled files"
  task :sync do
    system "rsync -rbv #{plugin_path}/app/helpers/application_helper.rb app/helpers"
    system "rsync -rbv #{plugin_path}/app/helpers/layout_helper.rb app/helpers"
    system "rsync -ruv #{plugin_path}/config/authorization_rules.rb config"
    system "rsync -ruv #{plugin_path}/config/initializers config"
    system "rsync -ruv #{plugin_path}/config/notifier.yml config"
    system "rsync -rbv #{plugin_path}/config/locales config"
    system "rsync -ruv #{plugin_path}/cucumber.yml ."
    # system "rsync -ruv #{plugin_path}/public ."
  end

  begin
    require 'cucumber/rake/task'

    # Use vendored cucumber binary if possible. If it's not vendored,
    # Cucumber::Rake::Task will automatically use installed gem's cucumber binary
    vendored_cucumber_binary = Dir["#{RAILS_ROOT}/vendor/{gems,plugins}/cucumber*/bin/cucumber"].first

    Cucumber::Rake::Task.new({:features => 'db:test:prepare'}, "Run Features of authlogic_bundle with Cucumber") do |t|
      t.binary = vendored_cucumber_binary
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
