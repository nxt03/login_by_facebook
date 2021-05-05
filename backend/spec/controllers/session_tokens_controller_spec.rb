require 'rails_helper'

RSpec.describe SessionTokensController, type: :controller do

  describe 'POST #create' do

    context 'short-lived access token is empty' do
      before { post :create, params: { session_token: { access_token: nil } } }

      it { expect(response).to have_http_status(:bad_request) }
      it { expect(JSON.parse(response.body)['error']).to eq('No short-lived access token provided.') }
    end

    context 'short-lived access token is present' do

      context 'invalid' do
        before { post :create, params: { session_token: { access_token: 'some_stranged_access_token' } } }

        it { expect(response).to have_http_status(:ok) }
        it { expect(JSON.parse(response.body)['error']).to eq('Can not obtain the long-lived access token, please try again.') }
      end

      context 'valid but missing user name' do
        before { post :create, params: {
            session_token: {
              name: '',
              email: 'user_a@gmail.com',
              provider_id: '000000000',
              access_token: 'faked_short_lived_access_token'
            }
          }
        }

        it { expect(response).to have_http_status(:ok) }
        it { expect(JSON.parse(response.body)['error']).to eq('Can not create new user, please try again.') }
      end

      context 'valid but missing email' do
        before { post :create, params: {
            session_token: {
              name: 'User A',
              email: '',
              provider_id: '000000000',
              access_token: 'faked_short_lived_access_token'
            }
          }
        }

        it { expect(response).to have_http_status(:ok) }
        it { expect(JSON.parse(response.body)['error']).to eq('Can not create new user, please try again.') }
      end

      context 'valid but missing provider id' do
        before { post :create, params: {
            session_token: {
              name: 'User A',
              email: 'user_a@gmail.com',
              provider_id: '',
              access_token: 'faked_short_lived_access_token'
            }
          }
        }

        it { expect(response).to have_http_status(:ok) }
        it { expect(JSON.parse(response.body)['error']).to eq('Can not create new user, please try again.') }
      end

      context 'valid but user is created before' do
        let(:user) { create(:user) }

        before { post :create, params: {
            session_token: {
              name: user.name,
              email: user.email,
              provider_id: user.provider_id,
              access_token: 'faked_short_lived_access_token'
            }
          }
        }

        it { expect(response).to have_http_status(:ok) }
        it { expect(JSON.parse(@response.body)['user']['id']).to eq(user.id) }
        it { expect(JSON.parse(@response.body)['user']['name']).to eq(user.name) }
        it { expect(JSON.parse(@response.body)['user']['email']).to eq(user.email) }
        it { expect(JSON.parse(@response.body)['user']['access_token']).to eq(user.access_token) }
        it { expect(JSON.parse(@response.body)['user']['provider']).to eq(user.provider) }
        it { expect(JSON.parse(@response.body)['user']['provider_id']).to eq(user.provider_id) }
        it { expect(JSON.parse(@response.body)['user']['expired_at'].to_datetime.to_i).to eq(user.expired_at.to_i) }
      end

      context 'valid and user not created before' do
        before { post :create, params: {
            session_token: {
              name: 'User B',
              email: 'user_b@gmail.com',
              provider_id: '1111111111',
              access_token: 'faked_short_lived_access_token'
            }
          }
        }

        let(:user) { User.first }

        it { expect(response).to have_http_status(:ok) }
        it { expect(JSON.parse(@response.body)['user']['id']).to eq(user.id) }
        it { expect(JSON.parse(@response.body)['user']['name']).to eq(user.name) }
        it { expect(JSON.parse(@response.body)['user']['email']).to eq(user.email) }
        it { expect(JSON.parse(@response.body)['user']['access_token']).to eq(user.access_token) }
        it { expect(JSON.parse(@response.body)['user']['provider']).to eq(user.provider) }
        it { expect(JSON.parse(@response.body)['user']['provider_id']).to eq(user.provider_id) }
        it { expect(JSON.parse(@response.body)['user']['expired_at'].to_datetime.to_i).to eq(user.expired_at.to_i) }
      end

    end

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
