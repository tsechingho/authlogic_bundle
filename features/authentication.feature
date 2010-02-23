Feature: Authentication
  As a confirmed but anonymous user
  I want to login to the application
  So that I can be productive

  Scenario: Display login form to anonymous users
    Given "sharon" is an anonymous user
    When I go to the login page
    Then I should see a login form

  Scenario: Redirect to account page when user is logged in
    Given "sharon" a logged in user
    When I go to the login page
    Then I should be logged in
    When I follow "Logout"
    Then I should be logged out

  Scenario: Not allow login of an unconfirmed user
    Given "sharon" a notified but unconfirmed user
    When I go to the login page
    And I fill in "login" with "sharon"
    And I fill in "password" with "secret"
    And I press "Login"
    Then I should not be logged in
    And I should see "Your account is not active"
    And I should see "is not valid" within "#user_session_password_input"

  Scenario: Allow login of a user with valid credentials
    Given "sharon" a confirmed user with password "secret"
    When I go to the login page
    And I fill in "login" with "sharon"
    And I fill in "password" with "secret"
    And I press "Login"
    Then I should be logged in
    When I follow "Logout"
    Then I should be logged out

  Scenario Outline: Not allow login of a user with bad credentials
    Given "sharon" a confirmed user with password "secret"
    When I go to the login page
    And I fill in "login" with "<login>"
    And I fill in "password" with "<password>"
    And I press "Login"
    Then I should not be logged in
    And I should see "<error_message>" within "<selector>"

    Examples:
      | login   | password   | error_message                                      | selector                     |
      |         |            | You did not provide any details for authentication | #errorExplanation            |
      |         |  secret    | can not be blank                                   | #user_session_login_input    |
      |         | bad secret | can not be blank                                   | #user_session_login_input    |
      | unknown |            | can not be blank                                   | #user_session_password_input |
      | unknown |  secret    | is not valid                                       | #user_session_login_input    |
      | unknown | bad secret | is not valid                                       | #user_session_login_input    |
      | sharon  |            | can not be blank                                   | #user_session_password_input |
      | sharon  | bad secret | is not valid                                       | #user_session_password_input |

  Scenario: Allow a confirmed user to login and be remembered
    Given "sharon" a confirmed user with password "secret"
    When I go to the login page
    And I fill in "login" with "sharon"
    And I fill in "password" with "secret"
    And I check "Remember me"
    And I press "Login"
    Then I should be logged in
    When I open the homepage in a new window with cookies
    Then I should be logged in
    When I follow "Logout"
    Then I should be logged out

