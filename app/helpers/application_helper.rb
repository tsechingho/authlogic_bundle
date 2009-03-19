# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def secure_mail_to(email)
    mail_to email, nil, :encode => 'javascript'
  end

  def at(klass, attribute, options = {})
    klass.human_attribute_name(attribute.to_s, options = {})
  end

  def openid_link
    link_to at(User, :openid_identifier), "http://openid.net/"
  end
end
