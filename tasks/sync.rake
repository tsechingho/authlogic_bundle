namespace :authlogic_bundle do
  plugin_path = "vendor/plugins/authlogic_bundle"

  desc "Sync bundled files"
  task :sync do
    system "rsync -ruv #{plugin_path}/config/notifier.yml config"
    system "rsync -ruv #{plugin_path}/config/initializers config"
    system "rsync -ruv #{plugin_path}/app/views/user_mailer app/views"
  end
end