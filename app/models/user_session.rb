class UserSession < Authlogic::Session::Base
  # We reset Authorization.current_user back to GuestUser after UserSession.destroy
  # because current_user_session.record will be set nil.
  after_destroy :set_current_user_for_model_security

  protected

  def set_current_user_for_model_security
    Authorization.current_user = record
  end
end