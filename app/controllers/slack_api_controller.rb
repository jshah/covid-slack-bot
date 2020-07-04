# frozen_string_literal: true

# Handles API events from Slack
class SlackApiController < ApplicationController
  def covid
    current_state_values = CovidTracking.current_values('CA')
    positive = current_state_values['positive']
    negative = current_state_values['negative']
    render json: render_slack_response("positive: #{positive}, negative: #{negative}"), status: :ok
  end

  private

  def render_slack_response(text)
    {
      blocks: [
        {
          type: 'section',
          text: {
            type: 'mrkdwn',
            text: text
          }
        },
        {
          type: 'section',
          text: {
            type: 'mrkdwn',
            text: 'Partly cloudy today and tomorrow'
          }
        }
      ]
    }.to_json
  end
end
