# frozen_string_literal: true

# Wrapper for HTTPS requests to https://slack.com/api
class SlackOauthExchangeApi
  include HTTParty
  base_uri 'https://slack.com/api'

  def self.exchange_code_for_access_token(code)
    response = post(
      '/oauth.v2.access',
      body: {
        client_id: ENV['SLACK_CLIENT_ID'],
        code: code,
        client_secret: ENV['SLACK_CLIENT_SECRET']
      }
    )
    JSON.parse(response.body, symbolize_names: true)
  end
end

