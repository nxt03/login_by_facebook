Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resource :session_token, only: [:create] do

    post :auth, on: :collection

  end

end
