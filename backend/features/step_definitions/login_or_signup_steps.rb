# Scenario: Homepage loads properly, open Facebook popup
Given(/^I am a user who visit the homepage$/) do
  visit(@frontend_url)
end

Then(/^I should see the login button with title "(.+)"$/) do |button_title|
  expect(page).to have_content(button_title)
end

When(/^I click on "(.+)" button$/) do |button_title|
  click_button(button_title)
end

Then(/^the Facebook login popup should open$/) do
  expect(page.driver.browser.window_handles.second).to be_present
end

Then(/^I close the Facebook popup without login yet$/) do
  login_popup = page.driver.browser.window_handles.second
  page.driver.browser.switch_to.window(login_popup)
  page.driver.browser.close
end

Then(/^server should keep me at the homepage$/) do
  homepage = page.driver.browser.window_handles.first
  page.driver.browser.switch_to.window(homepage)
end

And(/^I should see the login button with title "(.+)" again$/) do |button_title|
  expect(page).to have_content(button_title)
end

When(/^I click on "(.+)" button again$/) do |button_title|
  click_button(button_title)
end

Then(/^the Facebook login popup should open again$/) do
  expect(page.driver.browser.window_handles.second).to be_present
end

Then(/^I fill correct email "(.+)" and password "(.+)" into it$/) do |email, password|
  login_popup = page.driver.browser.window_handles.second
  page.driver.browser.switch_to.window(login_popup)
  find('#email').set(email)
  find('#pass').set(password)
end

Then(/^I click on "(.+)"$/) do |button_title|
  click_button(button_title)
end

Then(/^server will redirect to my profile page with "(.+)" button$/) do |button_title|
  homepage = page.driver.browser.window_handles.first
  page.driver.browser.switch_to.window(homepage)
  expect(page).to have_content(button_title)
end

And(/^I should see my profile display with email "(.+)"$/) do |email|
  expect(page).to have_content(email)
end

And(/^I expect authentication cookie should be set in my browser$/) do
  browser = Capybara.current_session.driver.browser.manage
  expect(browser.cookie_named('auth')[:value]).to be_present
end

When(/^I refresh the browser$/) do
  page.driver.browser.navigate.refresh
end

Then(/^server should stay in my profile page$/) do
  expect(page).to have_current_path('/profile')
end

And(/^I should see my profile display with email "(.+)" again$/) do |email|
  expect(page).to have_content(email)
end

When(/^I click on "(.+)" button in profile page$/) do |button_title|
  click_button(button_title)
end

Then(/^server should redirect to homepage$/) do
  expect(page).to have_current_path('/')
end

And(/^I should see the button "(.+)" again$/) do |button_title|
  expect(page).to have_content(button_title)
end

And(/^I expect authentication cookie should be remove from my browser$/) do
  browser = Capybara.current_session.driver.browser.manage
  expect{ browser.cookie_named('auth') }.to raise_error(Selenium::WebDriver::Error::NoSuchCookieError)
end

When(/^I refresh the browser again after logout$/) do
  page.driver.browser.navigate.refresh
end

Then(/^server should keep current stay in the homepage$/) do
  expect(page).to have_current_path('/')
end
