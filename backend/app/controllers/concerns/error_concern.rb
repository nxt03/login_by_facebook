module ErrorConcern

  class AccessTokenError < StandardError; end
  class UserCreatedError < StandardError; end
  class InvalidUserError < StandardError; end
  class NoAccessTokenError < StandardError; end

  extend ActiveSupport::Concern

  included do
    rescue_from AccessTokenError, with: :render_access_token_error
    rescue_from ActiveRecord::RecordInvalid, with: :render_user_created_error
    rescue_from InvalidUserError, with: :render_invalid_user_error
    rescue_from ActionController::ParameterMissing, with: :render_malformed_params_error
    rescue_from NoAccessTokenError, with: :render_no_access_token_error
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

  def render_malformed_params_error
    render json: { error: 'Malformed params detected.' }, status: :bad_request
  end

  def render_no_access_token_error
    render json: { error: 'No short-lived access token provided.' }, status: :bad_request
  end

end
