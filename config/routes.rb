# frozen_string_literal: true

Rails.application.routes.draw do
  post '/covid_state_data', to: 'slack_api#covid_state_data'
  post '/covid_usa_data', to: 'slack_api#covid_usa_data'
end
