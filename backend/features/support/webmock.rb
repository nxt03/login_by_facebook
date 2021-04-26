require 'webmock/cucumber'

client_id = ENV['FACEBOOK_APP_ID']
client_secret = ENV['FACEBOOK_APP_SECRET']
facebook_url = ENV['FACEBOOK_OAUTH_URL']

WebMock
  .stub_request(:get, "#{facebook_url}/oauth/access_token?client_id=#{client_id}&client_secret=#{client_secret}&fb_exchange_token=faked_short_lived_access_token&grant_type=fb_exchange_token")
  .with(
    headers: {
    'Accept'=>'*/*',
    'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
    'User-Agent'=>'Ruby'
    })
  .to_return(status: 200, body: '{"access_token":"faked_long_lived_access_token","expires_in":5184000}', headers: { content_type: 'application/json' })
