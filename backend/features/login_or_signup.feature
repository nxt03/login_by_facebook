Feature: Login or Signup
  In order to login or signup
  As a user
  I need to go to homepage

  Scenario: Homepage loads properly, open Facebook popup
    Given I am a user who visit the homepage
    Then I should see the login button with title "Đăng nhập Facebook"
    When I click on "Đăng nhập Facebook" button
    Then the Facebook login popup should open
    Then I close the Facebook popup without login yet
    Then server should keep me at the homepage
    And I should see the login button with title "Đăng nhập Facebook" again
    When I click on "Đăng nhập Facebook" button again
    Then the Facebook login popup should open again
    Then I fill correct email "lihflafvcw_1619248783@tfbnw.net" and password "T123456" into it
    Then I click on "Đăng nhập"
    And server will redirect to my profile page with "Đăng xuất" button
    And I should see my profile display with email "lihflafvcw_1619248783@tfbnw.net"
    And I expect authentication cookie should be set in my browser
    When I refresh the browser
    Then server should stay in my profile page
    And I should see my profile display with email "lihflafvcw_1619248783@tfbnw.net" again
    When I click on "Đăng xuất" button in profile page
    Then server should redirect to homepage
    And I should see the button "Đăng nhập Facebook" again
    And I expect authentication cookie should be remove from my browser
    When I refresh the browser again after logout
    Then server should keep current stay in the homepage
