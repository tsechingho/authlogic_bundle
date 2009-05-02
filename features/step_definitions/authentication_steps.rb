Given /^"(.*)" a logged in user$/ do |name|
  Given "\"#{name}\" a confirmed user with password \"secret\""
  When "I go to the login page"
  And "I fill in \"login\" with \"sharon\""
  And "I fill in \"password\" with \"secret\""
  And "I press \"Login\""
  Then "I should see my account page"
end

Given /^I should see a login form$/ do
  response.should contain("Login")
  response.should contain("Password")
  response.should contain("Remember me")
  response.should contain("Open ID")
end

When /^I open the homepage in a new window$/ do
  new_window = ::Webrat.session_class.new(self)
  new_window.visit root_path
end