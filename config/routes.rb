Rails.application.routes.draw do
  devise_for :users,
    path_names: {
      sign_in: 'signin',
      sign_out: 'signout',
      sign_up: 'signup'
    }

  authenticated :user do
    root to: redirect('/dashboard'),
      as: :authenticated_root

    resources :dashboard,
      only: [:index]
  end

  # TODO: move to raw asset and put on CDN
  get '/:api_key/signupsumo.:format',
    to: 'scripts#show',
    api_key: /[0-9a-f]{32}/i,
    format: :js

  root 'pages#home'

  resource :styleguide,
    only: [:show]

  scope '/api' do
    scope '/v1' do
      # TODO: change this to be more restful
      match '/signups' => 'signups#create', via: [:get, :post]
    end
  end

  # TODO: move to pages controller
  if Rails.env.development?
    get 'scripts/test',
      to: 'scripts#test'
  end
end
