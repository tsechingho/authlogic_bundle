module AuthlogicBundle
  module User
    module ClassMethods
      def password_salt_is_changed?
        password_salt_field ? "#{password_salt_field}_changed?".to_sym : nil
      end
    end

    module InstanceMethods
      def active?
        self.state == 'active'
      end

      def signup!(user, &block)
        return save(true, &block) if session_class.activated? && openid_complete?
        return signup_by_openid!(user, &block) if respond_to?(:signup_by_openid!) && user && !user[:openid_identifier].blank?
        signup_without_credentials!(user, &block)
      end

      def signup_without_credentials!(user, &block)
        unless user.blank?
          self.login = user[:login] unless user[:login].blank?
          self.email = user[:email] unless user[:email].blank?
        end
        result = save_without_session_maintenance
        yield(result) if block_given?
        result
      end

      def to_param
        login.parameterize
      end
    end

    module PreferenceMethods
      def self.included(receiver)
        receiver.class_eval do
          has_one :preference, :class_name => "Preference", :foreign_key => "user_id"
          accepts_nested_attributes_for :preference, :allow_destroy => true
          attr_accessible :preference_attributes
          after_create :create_default_preference
        end
      end

      def create_default_preference
        create_preference if Preference.table_exists? && preference.nil?
      end
    end

    module AuthorizationMethods
      def self.included(receiver)
        receiver.class_eval do
          has_and_belongs_to_many :roles, :join_table => "user_roles"

          using_access_control

          # Since UserSession.find and UserSession.save will trigger 
          # record.save_without_session_maintenance(false) and the 'updated_at', 'last_request_at' 
          # fields of user model will be updated every time by authlogic if record (user) found.
          # We need to reset Authorization.current_user instead of giving the update privilege 
          # of user model to guest role, and use before_save filter in user model instead of 
          # after_find and before_save filters in UserSession model in case of other methods like 
          # reset_perishable_token! will call save_without_session_maintenance too.
          before_save :set_current_user_for_model_security
          # use after_save to create default role
          # every singed up user will have one role at least
          after_save :create_default_role
        end
      end

      def role_symbols
        (roles || []).map { |r| r.name.to_sym }
      end

      def assign_role(role)
        role_found = role.is_a?(::Role) ? role : ::Role.find_by_name(role.to_s)
        roles << role_found if role_found
      end

      protected

      def set_current_user_for_model_security
        ::Authorization.current_user = self
      end

      def create_default_role
        return unless roles.empty?
        ::Role.first ? ::Role.first : ::Role.find_or_create_by_name(:name => 'customer', :title => 'Customer')
        assign_role(::Role.first)
      end
    end

    module AuthlogicOpenIdMethods
      def self.included(receiver)
        receiver.class_eval do
          # extend/include methods of authlogic-oid in case of no methods found
          extend AuthlogicOpenid::ActsAsAuthentic::Config
          include AuthlogicOpenid::ActsAsAuthentic::Methods

          attr_accessible :openid_identifier

          openid_required_fields [:nickname, :email]
          openid_optional_fields [:fullname, :dob, :gender, :postcode, :country, :language, :timezone]

          # hack by alias_method_chain for authlogic-oid
          alias_method_chain :map_openid_registration, :persona_fields
        end
      end

      def signup_by_openid!(user, &block)
        unless user.blank?
          self.login = user[:login] unless user[:login].blank?
          self.email = user[:email] unless user[:email].blank?
          self.openid_identifier = user[:openid_identifier]
        end
        save(true, &block)
      end

      private

      # fetch persona from openid.sreg parameters returned by openid server if supported
      # http://openid.net/specs/openid-simple-registration-extension-1_0.html
      def map_openid_registration_with_persona_fields(registration)
        self.nickname ||= registration["nickname"] if respond_to?(:nickname) && !registration["nickname"].blank?
        self.login ||= registration["nickname"] if respond_to?(:login) && !registration["nickname"].blank?
        self.email ||= registration["email"] if respond_to?(:email) && !registration["email"].blank?
        self.name ||= registration["fullname"] if respond_to?(:name) && !registration["fullname"].blank?
        self.first_name ||= registration["fullname"].split(" ").first if respond_to?(:first_name) && !registration["fullname"].blank?
        self.last_name ||= registration["fullname"].split(" ").last if respond_to?(:last_name) && !registration["fullname"].blank?
        self.birthday ||= registration["dob"] if respond_to?(:birthday) && !registration["dob"].blank?
        self.gender ||= registration["gender"] if respond_to?(:gender) && !registration["gender"].blank?
        self.postcode ||= registration["postcode"] if respond_to?(:postcode) && !registration["postcode"].blank?
        self.country ||= registration["country"] if respond_to?(:country) && !registration["country"].blank?
        self.language ||= registration["language"] if respond_to?(:language) && !registration["language"].blank?
        self.timezone ||= registration["timezone"] if respond_to?(:timezone) && !registration["timezone"].blank?
      end

      # Since we use attr_accessible or attr_protected,
      # we should overwrite this method defined in authlogic_openid.
      def map_saved_attributes(attrs)
        attrs.each do |key, value|
          send("#{key}=", value)
        end
      end
    end

    module ActivationMethods
      # Since openid_identifier= will trigger openid authentication,
      # we need to save with block to prevent double render/redirect error.
      def activate!(user, &block)
        unless user.blank?
          self.password = user[:password]
          self.password_confirmation = user[:password_confirmation]
          self.openid_identifier = user[:openid_identifier]
        end
        self.state = 'active'
        save(true, &block)
      end

      def deliver_activation_instructions!
        # skip reset perishable token since we don't set roles in signup!
        reset_perishable_token! unless roles.blank?
        UserMailer.deliver_activation_instructions(self)
      end

      def deliver_activation_confirmation!
        reset_perishable_token!
        UserMailer.deliver_activation_confirmation(self)
      end
    end

    module PasswordResetMethods
      # Since password reset doesn't need to change openid_identifier,
      # we save without block as usual.
      def reset_password_with_params!(user)
        self.class.ignore_blank_passwords = false
        self.password = user[:password]
        self.password_confirmation = user[:password_confirmation]
        save
      end

      def deliver_password_reset_instructions!
        reset_perishable_token!
        UserMailer.deliver_password_reset_instructions(self)
      end
    end

    def self.included(receiver)
      receiver.extend ClassMethods
      receiver.send :include, InstanceMethods
      receiver.send :include, PreferenceMethods
      receiver.send :include, AuthlogicOpenIdMethods
      receiver.send :include, AuthorizationMethods
      receiver.send :include, ActivationMethods
      receiver.send :include, PasswordResetMethods
      receiver.class_eval do
        attr_accessible :login, :email, :password, :password_confirmation

        crypto_provider Authlogic::CryptoProviders::BCrypt
        merge_validates_length_of_password_field_options :on => :update
        merge_validates_confirmation_of_password_field_options :on => :update, :if => :password_salt_is_changed?
        merge_validates_length_of_password_confirmation_field_options :on => :update
      end
    end
  end
end
