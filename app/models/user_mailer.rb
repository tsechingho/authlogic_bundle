class UserMailer < ActionMailer::Base
  default_url_options[:host] = NOTIFIER[:host]

  def activation_instructions(user)
    subject       I18n.t('user_mailer.titles.activation_instructions')
    from          "#{NOTIFIER[:name]} <#{NOTIFIER[:email]}>"
    recipients    user.email
    sent_on       Time.now
    body          :account_activation_url => register_url(user.perishable_token)
  end

  def activation_confirmation(user)
    subject       I18n.t('user_mailer.titles.activation_confirmation')
    from          "#{NOTIFIER[:name]} <#{NOTIFIER[:email]}>"
    recipients    user.email
    sent_on       Time.now
    body          :root_url => root_url
  end

  def password_reset_instructions(user)
    subject       I18n.t('user_mailer.titles.password_reset_instructions')
    from          "#{NOTIFIER[:name]} <#{NOTIFIER[:email]}>"
    recipients    user.email
    sent_on       Time.now
    body          :edit_password_reset_url => edit_password_reset_url(user.perishable_token)
  end
end
