# Setup environment file for Webmock stubbing
client_id = ENV['FACEBOOK_APP_ID']
client_secret = ENV['FACEBOOK_APP_SECRET']
facebook_url = ENV['FACEBOOK_OAUTH_URL']
#====================================================================================

# Scenario: Backend receive empty short-lived access token from frontend
Given(/^I am a user who send params to backend without short-lived access token$/) do
  @response = post session_token_path, { session_token: { access_token: nil } }
end

Then(/^backend should return bad status response with no access token to frontend$/) do
  expect(@response.status).to eq(400)
  expect(JSON.parse(@response.body)['error']).to eq('No short-lived access token provided.')
end

# Scenario: Backend receive short-lived access token from frontend but that token is invalid
Given(/^I am a user who send params to backend with short-lived access token but its invalid$/) do
  stub_request(:get, "#{facebook_url}/oauth/access_token?client_id=#{client_id}&client_secret=#{client_secret}&fb_exchange_token=some_stranged_access_token&grant_type=fb_exchange_token")
  .with(
    headers: {
    'Accept'=>'*/*',
    'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
    'User-Agent'=>'Ruby'
    })
  .to_return(status: 400, body: '{"error":"invalid short-lived access token"}', headers: { content_type: 'application/json' })

  @response = post session_token_path, { session_token: { access_token: 'some_stranged_access_token' } }
end

Then(/^backend should return response with invalid token to frontend$/) do
  expect(@response.status).to eq(200)
  expect(JSON.parse(@response.body)['error']).to eq('Can not obtain the long-lived access token, please try again.')
end

# Scenario: Backend receive valid short-lived access token from frontend but missing user name
Given(/^I am a user who send params to backend with valid short-lived access token but missing user name$/) do

  # Preparation
  stub_request(:get, "#{facebook_url}/oauth/access_token?client_id=#{client_id}&client_secret=#{client_secret}&fb_exchange_token=faked_short_lived_access_token&grant_type=fb_exchange_token")
  .with(
    headers: {
    'Accept'=>'*/*',
    'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
    'User-Agent'=>'Ruby'
    })
  .to_return(status: 200, body: '{"access_token":"faked_long_lived_access_token","expires_in":5184000}', headers: { content_type: 'application/json' })

  # Action
  @response = post session_token_path, {
    session_token: {
      name: '',
      email: 'user_a@gmail.com',
      provider_id: '000000000',
      access_token: 'faked_short_lived_access_token'
    }
  }
end

Then(/^backend should return user created error to frontend because of missing name params$/) do
  expect(@response.status).to eq(200)
  expect(JSON.parse(@response.body)['error']).to eq('Can not create new user, please try again.')
end

# Scenario: Backend receive valid short-lived access token from frontend but missing email
Given(/^I am a user who send params to backend with valid short-lived access token but missing email$/) do

  # Prepration
  stub_request(:get, "#{facebook_url}/oauth/access_token?client_id=#{client_id}&client_secret=#{client_secret}&fb_exchange_token=faked_short_lived_access_token&grant_type=fb_exchange_token")
  .with(
    headers: {
    'Accept'=>'*/*',
    'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
    'User-Agent'=>'Ruby'
    })
  .to_return(status: 200, body: '{"access_token":"faked_long_lived_access_token","expires_in":5184000}', headers: { content_type: 'application/json' })

  # Action
  @response = post session_token_path, {
    session_token: {
      name: 'User A',
      email: '',
      provider_id: '000000000',
      access_token: 'faked_short_lived_access_token'
    }
  }
end

Then(/^backend should return user created error to frontend because of missing email params$/) do
  expect(@response.status).to eq(200)
  expect(JSON.parse(@response.body)['error']).to eq('Can not create new user, please try again.')
end

# Scenario: Backend receive valid short-lived access token from frontend but missing provider id
Given(/^I am a user who send params to backend with valid short-lived access token but missing provider id$/) do

  # Preparation
  stub_request(:get, "#{facebook_url}/oauth/access_token?client_id=#{client_id}&client_secret=#{client_secret}&fb_exchange_token=faked_short_lived_access_token&grant_type=fb_exchange_token")
  .with(
    headers: {
    'Accept'=>'*/*',
    'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
    'User-Agent'=>'Ruby'
    })
  .to_return(status: 200, body: '{"access_token":"faked_long_lived_access_token","expires_in":5184000}', headers: { content_type: 'application/json' })

  # Action
  @response = post session_token_path, {
    session_token: {
      name: 'User A',
      email: 'user_a@gmail.com',
      provider_id: '',
      access_token: 'faked_short_lived_access_token'
    }
  }
end

Then(/^backend should return user created error to frontend because of missing provider id params$/) do
  expect(@response.status).to eq(200)
  expect(JSON.parse(@response.body)['error']).to eq('Can not create new user, please try again.')
end

# Scenario: Backend receive all valid params from frontend and request user is already created
Given(/^I am a user who authenticated before, now I send params to backend again$/) do

  # Preparation
  old_user = User.create(name: 'User A', email: 'user_a@gmail.com', provider_id: '000000000', access_token: 'faked_short_lived_access_token')
  stub_request(:get, "#{facebook_url}/oauth/access_token?client_id=#{client_id}&client_secret=#{client_secret}&fb_exchange_token=faked_short_lived_access_token&grant_type=fb_exchange_token")
  .with(
    headers: {
    'Accept'=>'*/*',
    'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
    'User-Agent'=>'Ruby'
    })
  .to_return(status: 200, body: '{"access_token":"faked_long_lived_access_token","expires_in":5184000}', headers: { content_type: 'application/json' })

  # Action
  @response = post session_token_path, {
    session_token: {
      name: old_user.name,
      email: old_user.email,
      provider_id: old_user.provider_id,
      access_token: old_user.access_token
    }
  }
end

Then(/^backend find that user, update access token if needed and return to user succesffully$/) do
  old_user = User.first
  expect(@response.status).to eq(200)
  expect(User.count).to eq(1)
  expect(JSON.parse(@response.body)['user']['id']).to eq(old_user.id)
  expect(JSON.parse(@response.body)['user']['name']).to eq(old_user.name)
  expect(JSON.parse(@response.body)['user']['email']).to eq(old_user.email)
  expect(JSON.parse(@response.body)['user']['access_token']).to eq(old_user.access_token)
  expect(JSON.parse(@response.body)['user']['provider']).to eq(old_user.provider)
  expect(JSON.parse(@response.body)['user']['provider_id']).to eq(old_user.provider_id)
  expect(JSON.parse(@response.body)['user']['expired_at'].to_datetime.to_i).to eq(old_user.expired_at.to_i)
end

# Scenario: Backend receive new valid params from frontend
Given(/^I am a new user who send valid params to backend$/) do

  # Preparation
  old_user = User.create!(name: 'User A', email: 'user_a@gmail.com', provider_id: '000000000', provider: :facebook, expired_at: Time.now + 1.days, access_token: 'faked_short_lived_access_token_a')
  stub_request(:get, "#{facebook_url}/oauth/access_token?client_id=#{client_id}&client_secret=#{client_secret}&fb_exchange_token=faked_short_lived_access_token_b&grant_type=fb_exchange_token")
  .with(
    headers: {
    'Accept'=>'*/*',
    'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
    'User-Agent'=>'Ruby'
    })
  .to_return(status: 200, body: '{"access_token":"faked_short_lived_access_token_b","expires_in":5184000}', headers: { content_type: 'application/json' })

  # Action
  @response = post session_token_path, {
    session_token: {
      name: 'User B',
      email: 'user_b@gmail.com',
      provider_id: '1111111111',
      access_token: 'faked_short_lived_access_token_b'
    }
  }
end

Then(/^backend should create new user account return to me$/) do
  new_user = User.second
  expect(@response.status).to eq(200)
  expect(User.count).to eq(2)
  expect(JSON.parse(@response.body)['user']['id']).to eq(new_user.id)
  expect(JSON.parse(@response.body)['user']['name']).to eq(new_user.name)
  expect(JSON.parse(@response.body)['user']['email']).to eq(new_user.email)
  expect(JSON.parse(@response.body)['user']['access_token']).to eq(new_user.access_token)
  expect(JSON.parse(@response.body)['user']['provider']).to eq(new_user.provider)
  expect(JSON.parse(@response.body)['user']['provider_id']).to eq(new_user.provider_id)
  expect(JSON.parse(@response.body)['user']['expired_at'].to_datetime.to_i).to eq(new_user.expired_at.to_i)
end
