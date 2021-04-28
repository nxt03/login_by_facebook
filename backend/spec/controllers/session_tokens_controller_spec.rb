require 'rails_helper'

RSpec.describe SessionTokensController, type: :controller do

  describe 'POST #create' do
    # This controller action need to integrate with Facebook before it can continue
    # process, we will use Cucumber to test this controller action.
  end

  describe 'POST #auth' do

    let(:user) { create(:user) }

    context 'token is present' do

      context 'token match' do
        before { post :auth, params: { session_token: { token: user.access_token } } }

        it { expect(response).to have_http_status(:ok) }
        it { expect(JSON.parse(response.body)['user']['name']).to eq(user.name) }
        it { expect(JSON.parse(response.body)['user']['email']).to eq(user.email) }
        it { expect(JSON.parse(response.body)['user']['access_token']).to eq(user.access_token) }
        it { expect(JSON.parse(response.body)['user']['provider']).to eq(user.provider) }
        it { expect(JSON.parse(response.body)['user']['provider_id']).to eq(user.provider_id) }
        it { expect(JSON.parse(response.body)['user']['expired_at'].to_datetime.to_i).to be > Time.now.to_i }
      end

      context 'token not match' do
        before { post :auth, params: { session_token: { token: 'another_faked_token' } } }

        it { expect(response).to have_http_status(:bad_request) }
        it { expect(JSON.parse(response.body)['error']).to eq('User is not found or is expired, please re-signin again.') }
      end

      context 'token is expired' do
        let(:expired_user) { create(:user, expired_at: Time.now - 1.day) }
        before { post :auth, params: { session_token: { token: expired_user.access_token } } }

        it { expect(response).to have_http_status(:bad_request) }
        it { expect(JSON.parse(response.body)['error']).to eq('User is not found or is expired, please re-signin again.') }
      end

      context 'malformed token params' do
        before { post :auth, params: nil }

        it { expect(response).to have_http_status(:bad_request) }
        it { expect(JSON.parse(response.body)['error']).to eq('Malformed params detected.') }
      end

    end

    context 'token is blank' do
      before { post :auth, params: { session_token: { token: '' } } }

      it { expect(response).to have_http_status(:bad_request) }
      it { expect(JSON.parse(response.body)['error']).to eq('User is not found or is expired, please re-signin again.') }
    end

  end
end
