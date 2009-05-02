Given /^"([^\"]*)" a user who opened (?:his|her) reset password email$/ do |name|
  Given "\"#{name}\" a confirmed user with email \"#{name}@example.com\""
  When "I go to the reset password page"
  And "I fill in \"email\" with \"#{name}@example.com\""
  And "I press \"Reset my password\""
  Then "I should receive an email"
  When "I open the email"
  Then "I should see \"reset your password\" in the email"
end

Then /^I (?:should )?see a reset password form$/ do
  response.should contain('Forgot Password')
  response.should contain('Email')
end

Then /^I (?:should )?see a password modification form$/ do
  response.should contain('Change My Password')
  response.should contain('Password')
  response.should contain('Password confirmation')
end

Then /^I should not see a password modification form$/ do
  response.should_not contain('Change My Password')
end
