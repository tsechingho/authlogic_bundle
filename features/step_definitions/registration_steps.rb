Given /"([^\"]*)" is an anonymous user/ do |name|
  visit '/logout'
end

Given /^"([^\"]*)" an unconfirmed user$/ do |name|
  Given "\"#{name}\" is an anonymous user"
  When "I go to the registration form"
  Then "I should see the registration form"
  And "I fill in \"login\" with \"#{name}\""
  And "I fill in \"email\" with \"#{name}@example.com\""
  And "I press \"Register\""
  Then "I should have a successful registration"
end

Given /^"([^\"]*)" a notified but unconfirmed user$/ do |name|
  Given "\"#{name}\" an unconfirmed user"
  And "I should receive an email"
  When "I open the email"
  Then "I should see \"activate your account\" in the email body"
end

Given /^"([^\"]*)" a confirmed user with password "([^\"]*)"$/ do |name, password|
  Given "\"#{name}\" a notified but unconfirmed user"
  When "I follow \"activate your account\" in the email"
  And "I fill in \"set your password\" with \"#{password}\""
  And "I fill in \"password confirmation\" with \"#{password}\""
  And "I press \"Activate\""
  Then "I should have a successful activation"
  And "a clear email queue"
  When "I follow \"Logout\""
  Then "I should be logged out"
end

Given /^"([^\"]*)" a confirmed user with email "([^\"]*)"$/ do |name, email|
  Given "\"#{name}\" is an anonymous user"
  When "I go to the registration form"
  And "I fill in \"login\" with \"#{name}\""
  And "I fill in \"email\" with \"#{email}\""
  And "I press \"Register\""
  Then "I should receive an email"
  When "I open the email"
  And "I follow \"activate your account\" in the email"
  And "I fill in \"set your password\" with \"secret\""
  And "I fill in \"password confirmation\" with \"secret\""
  And "I press \"Activate\""
  Then "I should have a successful activation"
  And "a clear email queue"
  When "I follow \"Logout\""
  Then "I should be logged out"
end

Then /^I should see the registration form$/ do
  response.should contain('Login')
  response.should contain('Email')
end

Then /^I should see the activation form$/ do
  response.should contain('Set your password')
  response.should contain('Password confirmation')
  response.should contain('Open ID')
end

Then /^I should have a successful registration$/ do
  Then 'I should see "Your account has been created"'
end

Then /^I should have an unsuccessful registration$/ do
  Then 'I should not see "Your account has been created"'
end

Then /^I should have a successful activation$/ do
  Then "I should see my account editing page"
  And 'I should see "Your account has been activated"'
end

Then /^I should have an unsuccessful activation$/ do
  Then 'I should not see "Your account has been activated"'
end

Then /^I should be logged in$/ do
  Then 'I should see "My Account"'
end

Then /^I should not be logged in$/ do
  Then 'I should not see "My Account"'
end

Then /^I should be logged out$/ do
  Then 'I should not be logged in'
  And 'I should see "Logout successful!"'
end

Then /^I should see the home page$/ do
  Then 'I should see "Home"'
end

Then /^I should see my account page$/ do
  Then 'I should be on "the account page"'
  And 'I should see "User Account"'
end

Then /^I should not see my account page$/ do
  Then 'I should not see "User Account"'
end

Then /^I should see my account editing page$/ do
  Then 'I should be on "the account editing page"'
  And 'I should see "Editing user"'
end
