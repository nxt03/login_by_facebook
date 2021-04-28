Feature: Find or create new user
  In order to find or create new user
  As a frontend
  I need to send request with short-lived access token to backend

  Scenario: Backend receive empty short-lived access token from frontend
    Given I am a user who send params to backend without short-lived access token
    Then backend should return bad status response with no access token to frontend

  Scenario: Backend receive short-lived access token from frontend but that token is invalid
    Given I am a user who send params to backend with short-lived access token but its invalid
    Then backend should return response with invalid token to frontend

  Scenario: Backend receive valid short-lived access token from frontend but missing user name
    Given I am a user who send params to backend with valid short-lived access token but missing user name
    Then backend should return user created error to frontend because of missing name params

  Scenario: Backend receive valid short-lived access token from frontend but missing email
    Given I am a user who send params to backend with valid short-lived access token but missing email
    Then backend should return user created error to frontend because of missing email params

  Scenario: Backend receive valid short-lived access token from frontend but missing provider id
    Given I am a user who send params to backend with valid short-lived access token but missing provider id
    Then backend should return user created error to frontend because of missing provider id params

  Scenario: Backend receive all valid params from frontend and request user is already created
    Given I am a user who authenticated before, now I send params to backend again
    Then backend find that user, update access token if needed and return to user succesffully

  Scenario: Backend receive new valid params from frontend
    Given I am a new user who send valid params to backend
    Then backend should create new user account return to me
