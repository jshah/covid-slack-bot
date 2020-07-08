# frozen_string_literal: true

# Wrapper for HTTP requests to https://covidtracking.com/api
class CovidTrackingApi
  include HTTParty
  base_uri 'https://covidtracking.com'

  # Fetches current COVID data for state code.
  def current_data_for_state(state_code)
    raise ArgumentError, 'Must provide a state_code.' unless state_code.present?

    response = self.class.get("/api/v1/states/#{state_code.downcase}/current.json")
    JSON.parse(response.body, symbolize_names: true)
  end

  # Fetches historic COVID data for state code.
  def historic_data_for_state(state_code)
    raise ArgumentError, 'Must provide a state_code.' unless state_code.present?

    response = self.class.get("/api/v1/states/#{state_code.downcase}/daily.json")
    JSON.parse(response.body, symbolize_names: true)
  end

  # Fetches current COVID data for the United States.
  def current_data_for_usa
    response = self.class.get('/api/v1/us/current.json')
    JSON.parse(response.body, symbolize_names: true)
  end

  # Fetches historic COVID data for the United States.
  def historic_data_for_usa
    response = self.class.get('/api/v1/us/daily.json')
    JSON.parse(response.body, symbolize_names: true)
  end
end
