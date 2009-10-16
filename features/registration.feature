Feature: Registration
  In order to get my personal account
  As a anonymous user
  I want be able to register
  So that I can be a member of the community

  Scenario: Display registration form to anonymous user
    Given "sharon" is an anonymous user
    When I go to the homepage
    Then I should see "Register"
    When I follow "Register"
    Then I should see the registration form

  Scenario: Allow an anonymous user to create account
    Given "sharon" is an anonymous user
    When I go to the registration form
    And I fill in "login" with "sharon"
    And I fill in "email" with "sharon@example.com"
    And I press "Register"
    Then I should have a successful registration

  Scenario Outline: Not allow an anonymous user to create account with incomplete input
    Given "sharon" is an anonymous user
    When I go to the registration form
    And I fill in "login" with "<login>"
    And I fill in "email" with "<email>"
    And I press "Register"
    Then I should have an unsuccessful registration
    And I should see "<error_message>"

    Examples: incomplete registration inputs
      | login  | email              | error_message      |
      |        |                    | Login is too short |
      | sharon |                    | Email is too short |
      |        | sharon@example.com | Login is too short |

  Scenario: Send an activation instruction mail at a successful account creation
    Given "sharon" an unconfirmed user
    And I should receive an email
    When I open the email
    Then I should see "activate your account" in the email body

  Scenario: Want to confirm account using mail activation token
    Given "sharon" a notified but unconfirmed user
    When I follow "activate your account" in the email
    Then I should see the activation form

  Scenario: Do not confirm an account with invalid mail activation token
    Given "sharon" an unconfirmed user
    When I go to the confirm page with bad token
    Then I should see the home page

  Scenario: Activate account using mail activation token with password
    Given "sharon" a notified but unconfirmed user
    When I follow "activate your account" in the email
    And I fill in "set your password" with "secret"
    And I fill in "password confirmation" with "secret"
    And I press "Activate"
    Then I should have a successful activation
    And I should be logged in
    When I follow "Logout"
    Then I should be logged out

  Scenario Outline: Activate account using mail activation token with bad password
    Given "sharon" a notified but unconfirmed user
    When I follow "activate your account" in the email
    And I fill in "set your password" with "<password>"
    And I fill in "password confirmation" with "<confirmation>"
    And I press "Activate"
    Then I should have an unsuccessful activation
    And I should see "<error_message>"

    Examples: Bad password and confirmation combinations
      | password | confirmation | error_message                       |
      |          |              | Password is too short               |
      |  secret  |              | Password confirmation is too short  |
      |          | secret       | Password is too short               |
      |  secret  | not a secret | Password doesn't match confirmation |

  Scenario: Send an activation confirmation mail when user confirms account
    Given "sharon" a notified but unconfirmed user
    When I follow "activate your account" in the email
    And I fill in "set your password" with "secret"
    And I fill in "password confirmation" with "secret"
    And I press "Activate"
    Then I should be logged in
    And I should have 2 emails at all
    When I open the most recent email
    Then I should see "Activation Complete" in the email subject
    When I follow "Logout"
    Then I should be logged out

