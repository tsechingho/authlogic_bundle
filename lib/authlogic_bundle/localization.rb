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
        !language.blank? && languages_available.any? { |array| array.last == language }
      end

      # Rails.configuration.i18n.default_locale
      # I18n.default_locale
      def set_language(prefered = nil)
        session[:language] = prefered if language_verified?(prefered)
        ::I18n.locale = session[:language] || cookies[:language] || browser_language || ::Rails.configuration.i18n.default_locale || ::I18n.default_locale || 'en'
      end

      def time_zone_verified?(time_zone)
        !time_zone.blank?
      end

      # Rails.configuratin.time_zone
      # ActiveRecord::Base.default_timezone
      # Time.zone_default
      def set_time_zone(prefered = nil)
        prefered = nil unless time_zone_verified?(prefered)
        ::Time.zone = prefered || user_time_zone || ::Rails.configuration.time_zone || 'UTC'
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
        if language_verified?(params[:language])
          session[:language] = cookies[:language] = params[:language]
        elsif (session[:language].blank? or cookies[:language].blank?) && language_verified?(user_language)
          session[:language] = cookies[:language] = user_language
        elsif cookies[:language].blank? && language_verified?(browser_language)
          cookies[:language] = browser_language
        end
      end

      def user_language
        return Rails.cache.read('user_prefered_language') unless current_user
        Rails.cache.fetch('user_prefered_language') do
          user_locale = current_user.preferred_language
          language_verified?(user_locale) ? user_locale : nil
        end
      end

      def browser_language
        return unless http_lang = request.env["HTTP_ACCEPT_LANGUAGE"] and !http_lang.blank?
        browser_locale = http_lang[/^[a-z]{2}/i].downcase + '-' + http_lang[3,2].upcase
        browser_locale.sub!(/-US/, '')
        language_verified?(browser_locale) ? browser_locale : nil
      end

      def user_time_zone
        return Rails.cache.read('user_prefered_time_zone') unless current_user
        Rails.cache.fetch('user_prefered_time_zone') do
          time_zone = current_user.preferred_time_zone
          time_zone_verified?(time_zone) ? time_zone : nil
        end
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