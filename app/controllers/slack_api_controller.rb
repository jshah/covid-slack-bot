# frozen_string_literal: true

# Handles API events from Slack
class SlackApiController < ApplicationController
  def covid
    puts render_slack_response('CA')
    render json: render_slack_response('CA'), status: :ok
  end

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
