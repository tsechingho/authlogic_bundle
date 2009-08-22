ActionController::Base.class_eval do
  private

  # always return successful
  def begin_open_id_authentication(identity_url, options = {})
    yield OpenIdAuthentication::Result.new(:successful), self.normalize_identifier(identity_url), {}
  end
end
