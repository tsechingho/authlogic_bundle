module UsersHelper
  def authentication_toggle
    link_to_function t('users.authentication_token'), "$('password_box').toggle(); $('openid_box').toggle();"
  end
end
