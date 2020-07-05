# frozen_string_literal: true

# Wrapper for HTTP requests to https://covidtracking.com/api
class CovidTracking
  include HTTParty
  base_uri 'https://covidtracking.com'

  def current_data_for_state(state)
    raise ArgumentError, 'Must provide a state.' unless state.present?

    response = self.class.get("/api/v1/states/#{state}/current.json")
    JSON.parse(response.body, symbolize_names: true)
  end
end
