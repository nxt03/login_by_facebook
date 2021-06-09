class SessionTokensController < ApplicationController

  before_action :exchange_long_lived_token, only: [:create]

  def create
    user = find_or_create_user
    render json: { user: user }
  end

  def auth
    user = User.find_by(access_token: auth_token_params[:token])
    raise InvalidUserError if user.blank? || user.expired_at.to_i <= Time.now.to_i

    render json: { user: user }
  end

  private

  def auth_token_params
    params.require(:session_token).permit(:token)
  end

  def find_or_create_user
    user = User.find_by(provider_id: session_token_params[:provider_id])
    return User.create!(session_token_params) if user.blank?

    user.update(session_token_params)
    user
  end

  def session_token_params
    @session_token_params ||= params.require(:session_token).permit(
      :provider_id,
      :name,
      :email,
      :access_token
    )
  end

  def exchange_long_lived_token
    raise NoAccessTokenError if session_token_params[:access_token].blank?
    response = HTTParty.get(oauth_url, query: oauth_params)
    raise AccessTokenError if response.code != 200

    session_token_params.merge!(
      access_token: response.parsed_response['access_token'],
      provider: :facebook,
      expired_at: Time.now + response.parsed_response['expires_in'].seconds
    )
  end

  def oauth_url
    "#{ENV['FACEBOOK_OAUTH_URL']}/oauth/access_token"
  end

  def oauth_params
    {
      grant_type: 'fb_exchange_token',
      client_id: ENV['FACEBOOK_APP_ID'],
      client_secret: ENV['FACEBOOK_APP_SECRET'],
      fb_exchange_token: session_token_params[:access_token]
    }
  end

end
