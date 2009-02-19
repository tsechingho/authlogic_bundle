class UserMailer < ActionMailer::Base
  default_url_options[:host] = NOTIFIER[:host]

  def activation_instructions(user)
    subject       "Activation Instructions"
    from          "#{NOTIFIER[:name]} <#{NOTIFIER[:email]}>"
    recipients    user.email
    sent_on       Time.now
    body          :account_activation_url => register_url(user.perishable_token)
  end

  def activation_confirmation(user)
    subject       "Activation Complete"
    from          "#{NOTIFIER[:name]} <#{NOTIFIER[:email]}>"
    recipients    user.email
    sent_on       Time.now
    body          :root_url => root_url
  end

  def password_reset_instructions(user)
    subject       "Password Reset Instructions"
    from          "#{NOTIFIER[:name]} <#{NOTIFIER[:email]}>"
    recipients    user.email
    sent_on       Time.now
    body          :edit_password_reset_url => edit_password_reset_url(user.perishable_token)
  end
end
