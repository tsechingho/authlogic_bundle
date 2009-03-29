class User < ActiveRecord::Base
  acts_as_authentic do |c|
    c.crypto_provider = Authlogic::CryptoProviders::BCrypt
    c.validates_length_of_password_field_options = {:minimum => 4, :on => :update, :if => :require_password?}
    c.validates_confirmation_of_password_field_options = {:minimum => 4, :on => :update, :if => (password_salt_field ? "#{password_salt_field}_changed?".to_sym : nil)}
    c.validates_length_of_password_confirmation_field_options = {:minimum => 4, :on => :update, :if => :require_password?}
  end

  using_access_control

  has_many :roles

  validate :normalize_openid_identifier
  validates_uniqueness_of :openid_identifier, :allow_blank => true

  attr_accessible :login, :email, :password, :password_confirmation, :openid_identifier

  # Since UserSession.find and UserSession.save will trigger 
  # record.save_without_session_maintenance(false) and the 'updated_at', 'last_request_at' 
  # fields of user model will be updated every time by authlogic if record (user) found.
  # We need to reset Authorization.current_user instead of giving the update privilege 
  # of user model to guest role, and use before_save filter in user model instead of 
  # after_find and before_save filters in UserSession model in case of other methods like 
  # reset_perishable_token! will call save_without_session_maintenance too.
  before_save :set_current_user_for_model_security

  # we need to make sure that either a password or openid gets set
  # when the user activates his account
  def has_no_credentials?
    require_password? && self.openid_identifier.blank?
  end

  def active?
    self.state == 'active'
  end

  def signup!(user)
    self.login = user[:login]
    self.email = user[:email]
    save_without_session_maintenance
  end

  def activate!(user)
    self.state = 'active'
    self.password = user[:password]
    self.password_confirmation = user[:password_confirmation]
    self.openid_identifier = user[:openid_identifier]
    self.roles.build(:name => 'customer')
    save
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

  def deliver_password_reset_instructions!
    reset_perishable_token!
    UserMailer.deliver_password_reset_instructions(self)
  end

  def role_symbols
    (roles || []).map { |r| r.name.to_sym }
  end

  def to_param
    login.parameterize
  end

  protected

  def set_current_user_for_model_security
    Authorization.current_user = self
  end

  private

  def normalize_openid_identifier
    self.openid_identifier = OpenIdAuthentication.normalize_url(openid_identifier) if !openid_identifier.blank?
  rescue OpenIdAuthentication::InvalidOpenId => e
    errors.add(:openid_identifier, e.message)
  end
end
