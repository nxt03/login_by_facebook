class User < ApplicationRecord

  validates :name, :email, :access_token, :provider, :provider_id, :expired_at, presence: true

end
