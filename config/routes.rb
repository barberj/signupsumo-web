require 'sidekiq/web'

Rails.application.routes.draw do
  get 'errors/unprocessable'
  get 'errors/file_not_found'
  get 'errors/internal_server_error'

  match '/404', to: 'errors#file_not_found', via: :all
  match '/422', to: 'errors#unprocessable', via: :all
  match '/500', to: 'errors#internal_server_error', via: :all

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

    resource :subscription,
      only: [:show, :create]

    get '/docs' => 'pages#docs',
      as: :docs

    get '/home' => 'pages#home'
  end

  get '/terms' => 'pages#terms',
    as: :terms
  get '/privacy' => 'pages#privacy',
    as: :privacy

  post '/subscriptions/webhook' => 'subscriptions#stripe_hook', as: :stripe_hook

  root 'pages#home'

  resource :styleguide,
    only: [:show]

  scope '/api' do
    scope '/v1' do
      # TODO: change this to be more restful
      match '/signups' => 'signups#create', via: [:get, :post]
    end
  end

  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/sidekiq',
      as: :production_sidekiq
  end

  if Rails.env.development?
    get '/test',
      to: 'pages#test'

    mount Sidekiq::Web => '/sidekiq',
      as: :development_sidekiq
  end
end
