config = File.read(Rails.root.join('config', 'notifier.yml'))
NOTIFIER = YAML.load(config)[RAILS_ENV]['notifier'].symbolize_keys