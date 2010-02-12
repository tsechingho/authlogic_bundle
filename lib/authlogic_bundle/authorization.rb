module AuthlogicBundle
  module Authorization
    module ClassMethods
      def add_authorization_rules(rule)
        rules = send(:class_variable_get, :@@authorization_rules)
        rules ||= []
        rules << rule
        rules.flatten!
        rules.uniq!
        send(:class_variable_set, :@@authorization_rules, rules)
      end
    end

    module InstanceMethods
      protected

      def set_current_user_for_model_security
        ::Authorization.current_user = self.current_user
      end

      def permission_denied
        respond_to do |format|
          flash[:error] = t('users.flashs.errors.not_allowed')
          format.html { redirect_to(:back) rescue redirect_to(root_path) }
          format.xml  { head :unauthorized }
          format.js   { head :unauthorized }
        end
      end
    end

    # all rules and privilleges of each auth_dsl_file will be considered
    # in controller, @authorization_engine will be used
    # in model, Authorization::Engine.instance will be used
    # if Rails.env is development, a new Authorization::Engine.instance
    # will always be created without hacking
    def merge_authorization_rules
      reader = ::Authorization::Reader::DSLReader.new
      authorization_rules.each do |rule|
        if rule =~ /\.rb$/
          reader.parse File.read(rule) if File.exist? rule
        else
          reader.parse rule
        end
      end
      engine = ::Authorization::Engine.new(reader)
      @authorization_engine = engine # in_controller
      ::Authorization::Engine.send(:class_variable_set, :@@instance, engine) # in_model
      reader
    end

    def self.included(receiver)
      receiver.extend ClassMethods
      receiver.send :include, InstanceMethods
      receiver.class_eval do
        cattr_accessor :authorization_rules
        # If work with authlogic, we should set before_save in User instead.
        before_filter :set_current_user_for_model_security unless defined? ::Authorization
      end
    end
  end
end