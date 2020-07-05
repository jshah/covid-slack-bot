# frozen_string_literal: true

# Wrapper for HTTP requests to https://covidtracking.com/api
class CovidTracking
  include HTTParty
  base_uri 'https://covidtracking.com'

  # Fetches current COVID data for state code.
  def current_data_for_state(state_code)
    raise ArgumentError, 'Must provide a state_code.' unless state_code.present?

    response = self.class.get("/api/v1/states/#{state_code.downcase}/current.json")
    JSON.parse(response.body, symbolize_names: true)
  end
end
