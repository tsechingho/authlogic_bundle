module AuthlogicBundle
  module Localization
    module ClassMethods

    end

    module InstanceMethods
      def languages_available
        #@languages_available ||= I18n.load_path.collect do |locale_file|
        #  File.basename(File.basename(locale_file, '.rb'), '.yml')
        #end.uniq.sort
        @languages_available ||= [["English", "en"], ["繁體中文", "zh-TW"], ["简体中文", "zh-CN"]]
      end

      def language_verified?(language)
        languages_available.any? { |array| array.last == language }
      end

      def set_language(prefered = nil)
        session[:language] = prefered unless prefered.blank?
        ::I18n.locale = session[:language] || cookies[:language] || browser_language || ::I18n.default_locale || 'en'
      end

      private

      def set_localization
        languages_available
        persist_language
        set_language
        set_time_zone
        set_will_paginate_string
      end

      # browser must accept cookies
      def persist_language
        if !params[:language].blank? && language_verified?(params[:language])
          session[:language] = cookies[:language] = params[:language]
        elsif (session[:language].blank? or cookies[:language].blank?) && !user_language.blank?
          session[:language] = cookies[:language] = user_language
        elsif !browser_language.blank?
          cookies[:language] = browser_language
        end
      end

      def user_language
        return unless current_user && !current_user.preferred_language.blank?
        return unless language_verified?(current_user.preferred_language)
        current_user.preferred_language
      end

      def browser_language
        return unless http_lang = request.env["HTTP_ACCEPT_LANGUAGE"] and !http_lang.blank?
        browser_locale = http_lang[/^[a-z]{2}/i].downcase + '-' + http_lang[3,2].upcase
        browser_locale.sub!(/-US/, '')
        language_verified?(browser_locale) ? browser_locale : nil
      end

      def set_time_zone
        return unless current_user && !current_user.preferred_time_zone.blank?
        Time.zone = current_user.preferred_time_zone
      end

      # Because I18n.locale are dynamically determined in ApplicationController,
      # it should not put in config/initializers/will_paginate.rb
      def set_will_paginate_string
        return unless defined? WillPaginate
        WillPaginate::ViewHelpers.pagination_options[:previous_label] = t('common.previous_page')
        WillPaginate::ViewHelpers.pagination_options[:next_label] = t('common.next_page')
      end
    end

    def self.included(receiver)
      receiver.extend ClassMethods
      receiver.send :include, InstanceMethods
      receiver.class_eval do
        helper_method :languages_available
        before_filter :set_localization
      end
    end
  end
end