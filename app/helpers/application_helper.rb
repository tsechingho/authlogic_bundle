# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def secure_mail_to(email, name = nil)
    return name if email.blank?
    mail_to email, name, :encode => 'javascript'
  end

  def attr_translate(klass, attribute = nil, options = {})
    return klass.human_name(options) if attribute.blank?
    klass.human_attribute_name(attribute.to_s, options)
  end
  alias :at :attr_translate

  def flash_translate(key, options = {})
    I18n.t(key, :scope => [controller_name, action_name, :flash])
    I18n.t(key, {:scope => [controller_name, action_name, :flash]}.merge(options))
  end
  alias :ft :flash_translate

  def openid_link
    link_to at(User, :openid_identifier), "http://openid.net/"
  end
end
