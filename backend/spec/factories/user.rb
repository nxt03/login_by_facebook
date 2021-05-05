FactoryBot.define do
  factory :user, class: 'User' do
    name { 'User A' }
    email { 'user_a@gmail.com' }
    access_token { 'faked_long_lived_access_token' }
    provider { 'facebook' }
    provider_id { '000000000' }
    expired_at { Time.now + 60.days }

    trait :invalid_name do
      name { '' }
    end

  end
end
