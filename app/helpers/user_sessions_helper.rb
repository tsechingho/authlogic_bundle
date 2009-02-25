module UserSessionsHelper
  def login_toggle
    link_to_function t('user_sessions.login_token'), "$('password_box').toggle(); $('openid_box').toggle(); $('errorExplanation').toggle();"
  end
end
