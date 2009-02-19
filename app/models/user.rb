class User < ActiveRecord::Base
  acts_as_authentic :crypto_provider => Authlogic::CryptoProviders::BCrypt,
    :login_field_validation_options => { :if => :openid_identifier_blank? },
    :password_field_validation_options => { :if => :openid_identifier_blank? },
    :password_field_validates_length_of_options => { :on => :update, :if => :has_no_credentials? }

  validate :normalize_openid_identifier
  validates_uniqueness_of :openid_identifier, :allow_blank => true

  attr_accessible :login, :email, :password, :password_confirmation, :openid_identifier

  def openid_identifier_blank?
    openid_identifier.blank?
  end

  # we need to make sure that either a password or openid gets set
  # when the user activates his account
  def has_no_credentials?
    self.crypted_password.blank? && self.openid_identifier.blank?
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
    save
  end

  def to_param
    login.parameterize
  end

  def deliver_activation_instructions!
    reset_perishable_token!
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

  private

  def normalize_openid_identifier
    self.openid_identifier = OpenIdAuthentication.normalize_url(openid_identifier) if !openid_identifier.blank?
  rescue OpenIdAuthentication::InvalidOpenId => e
    errors.add(:openid_identifier, e.message)
  end
end
