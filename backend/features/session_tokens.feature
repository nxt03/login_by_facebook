Feature: Create new user
  In order to create new user
  As a frontend
  I need to send request with access token to backend

  Scenario: Create new user
    Given I am the user after login Facebook successfully
    Then frontend send POST request to backend to create new user
    Then backend return 1 new user to frontend
