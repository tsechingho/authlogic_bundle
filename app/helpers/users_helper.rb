module UsersHelper
  def authentication_toggle
    link_to_function t('users.authentication_token'), "$('password_box').toggle(); $('openid_box').toggle();"
  end
  
  def openid_link
    link_to t('activerecord.attributes.user.openid_identifier'), "http://openid.net/"
  end
end
