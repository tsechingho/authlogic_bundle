def load_yaml_file(file, &block)
  if File.exist? file
    config = YAML::load_file(file)
    if config.is_a?(Hash) && config.has_key?(Rails.env)
      setting = config[Rails.env].each do |k, v|
        v.symbolize_keys! if v.respond_to? :symbolize_keys!
      end
      yield setting if block_given?
    end
  end
end

load_yaml_file Rails.root.join('config', 'notifier.yml') do |config|
  NOTIFIER = config['notifier'] if config['notifier']
  ActionMailer::Base.default_content_type = config['default_content_type'] if config['default_content_type']
  ActionMailer::Base.delivery_method = config['delivery_method'] if config['delivery_method']
  ActionMailer::Base.smtp_settings = config['smtp_settings'] if config['smtp_settings']
end
