Given(/^I am the user after login Facebook successfully$/) do
  @params = {
    session_token: {
      provider_id: '000000000',
      name: 'User A',
      email: 'user_a@gmail.com',
      access_token: 'faked_short_lived_access_token'
    }
  }
end

Then(/^frontend send POST request to backend to create new user$/) do
  post session_token_path, @params
end

Then(/^backend return ([0-9]+) new user to frontend$/) do |count|
  expect(User.count).to eq(count.to_i)
  expect(User.first.access_token).to eq('faked_long_lived_access_token')
end
