module AuthlogicBundle
  class I18n
    class << self
      def t(key, options = {})
        if defined?(::I18n)
          ::I18n.t(key, options.merge(:scope => :authlogic_bundle))
        else
          options[:default]
        end
      end
    end
  end
end