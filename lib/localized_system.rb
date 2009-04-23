module LocalizedSystem
  module ClassMethods
    
  end
  
  module InstanceMethods
    private

    def set_locale
      session[:locale] = params[:locale] if params[:locale]
      if http_lang = request.env["HTTP_ACCEPT_LANGUAGE"] and ! http_lang.blank?
        browser_locale = http_lang[/^[a-z]{2}/i].downcase + '-' + http_lang[3,2].upcase
        browser_locale.sub!(/-US/, '')
      end
      I18n.locale = session[:locale] || cookies[:locale] || browser_locale || I18n.default_locale || 'en'

      set_will_paginate_string if defined? WillPaginate

      #@locales_available ||= I18n.load_path.collect do |locale_file|
      #  File.basename(File.basename(locale_file, '.rb'), '.yml')
      #end.uniq.sort
      @locales_available ||= [["English", "en"], ["繁體中文", "zh-TW"], ["简体中文", "zh-CN"]]
    end

    def set_will_paginate_string
      # Because I18n.locale are dynamically determined in ApplicationController, 
      # it should not put in config/initializers/will_paginate.rb
      WillPaginate::ViewHelpers.pagination_options[:previous_label] = t('common.previous_page')
      WillPaginate::ViewHelpers.pagination_options[:next_label] = t('common.next_page')
    end
  end
  
  def self.included(receiver)
    receiver.extend ClassMethods
    receiver.class_eval do
      include InstanceMethods
      before_filter :set_locale
    end
  end
end