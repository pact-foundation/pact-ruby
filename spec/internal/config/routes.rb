# frozen_string_literal: true

Rails.application.routes.draw do
  resources :pets
  post '/matt', to: 'matt#create'
end
