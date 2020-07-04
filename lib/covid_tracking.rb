# frozen_string_literal: true

# Wrapper for HTTP requests to https://covidtracking.com/api
class CovidTracking
  include HTTParty
  base_uri 'https://covidtracking.com'

  def self.current_values(state)
    response = self.class.get("api/v1/states/#{state}/current.json")
    JSON.parse(response)
  end
end