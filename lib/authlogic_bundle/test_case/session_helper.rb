module ActionController
  module Integration
    class Session
      def in_a_new_session
        previous_cookies = @cookies.clone
        previous_response = @response.clone

        session = Integration::Session.new
        @cookies = session.cookies
        @response = session.response
        yield session if block_given?

        @response = previous_response
        @cookies = previous_cookies
        session
      end

      def in_a_separate_session
        previous_response = @response.clone

        session = Integration::Session.new
        @response = nil
        yield session if block_given?

        @response = previous_response
        session
      end
    end
  end
end