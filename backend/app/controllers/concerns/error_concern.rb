module ErrorConcern

  class AccessTokenError < StandardError; end
  class UserCreatedError < StandardError; end
  class InvalidUserError < StandardError; end

  extend ActiveSupport::Concern

  included do
    rescue_from AccessTokenError, with: :render_access_token_error
    rescue_from UserCreatedError, with: :render_user_created_error
    rescue_from InvalidUserError, with: :render_invalid_user_error
  end

  private

  def render_access_token_error
    render json: { error: 'Can not obtain the long-lived access token, please try again.' }
  end

  def render_user_created_error
    render json: { error: 'Can not create new user, please try again.' }
  end

  def render_invalid_user_error
    render json: { error: 'User is not found or is expired, please re-signin again.' }, status: :bad_request
  end

end
