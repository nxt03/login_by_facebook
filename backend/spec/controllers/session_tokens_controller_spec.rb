require 'rails_helper'

RSpec.describe SessionTokensController, type: :controller do

  # Test verify user based on acccess token, if successfully return the user
  # otherwise, return bad status request with error message.
  describe 'POST #auth' do
    let(:user) do
      {
        name: 'User A',
        email: 'user_a@gmail.com',
        access_token: 'long_long_access_token',
        provider: 'facebook',
        provider_id: '0000000000000',
        expired_at: Time.now + 60.days
      }
    end

    context 'with valid token' do
      it 'returns successful response with user' do
        User.create!(user)
        post :auth, params: { session_token: { token: user[:access_token] } }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['user']['name']).to eq(user[:name])
        expect(JSON.parse(response.body)['user']['email']).to eq(user[:email])
        expect(JSON.parse(response.body)['user']['access_token']).to eq(user[:access_token])
        expect(JSON.parse(response.body)['user']['provider']).to eq(user[:provider])
        expect(JSON.parse(response.body)['user']['provider_id']).to eq(user[:provider_id])
      end
    end

    context 'with invalid token' do
      it 'returns a error response' do
        User.create!(user)
        post :auth, params: { session_token: { token: '' } }

        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)['error']).to eq('User is not found or is expired, please re-signin again.')
      end
    end

  end
end
