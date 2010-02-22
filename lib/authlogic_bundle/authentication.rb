module AuthlogicBundle
  module Authentication
    module ClassMethods

    end

    module InstanceMethods
      protected

      def current_user_session
        @current_user_session ||= ::UserSession.find
      end

      def current_user
        @current_user ||= current_user_session && current_user_session.record
      end

      def require_user
        unless current_user
          store_location
          flash[:notice] = t('users.flash.login_required')
          redirect_to login_url
          return false
        end
      end

      def require_no_user
        if current_user
          store_location
          flash[:notice] = t('users.flash.logout_required')
          redirect_to account_url
          return false
        end
      end

      def disallowed_urls
        @disallowed_urls ||= [signup_url, login_url, logout_url]
      end

      def store_location
        disallowed_urls.map! { |url| url[/\/\w+$/] }
        return if disallowed_urls.include?(request.request_uri)
        session[:return_to] = request.request_uri
      end

      def redirect_back_or_default(default)
        redirect_to(session[:return_to] || default)
        session[:return_to] = nil
      end
    end

    def self.included(receiver)
      receiver.extend ClassMethods
      receiver.send :include, InstanceMethods
      receiver.class_eval do
        helper_method :current_user_session, :current_user
        filter_parameter_logging :password, :password_confirmation
      end
    end
  end
end