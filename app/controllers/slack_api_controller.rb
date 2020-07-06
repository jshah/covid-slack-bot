# frozen_string_literal: true

# Handles API events from Slack
class SlackApiController < ApplicationController
  before_action :validate_command
  before_action :validate_text

  def covid_state_data
    slack_response = CovidStateData.call(params[:text])
    render json: slack_response, status: :ok
  end

  private

  def validate_command
    return if params[:command].present?
    render json: render_missing_command_response, status: :ok
  end

  def validate_text
    return if params[:text].present?
    render json: render_missing_command_parameter_response, status: :ok
  end

  def render_missing_command_response
    {
      blocks: [
        {
          type: 'section',
          text: {
            type: 'plain_text',
            text: 'Command must be provided.'
          }
        }
      ]
    }.to_json
  end

  def render_missing_command_parameter_response
    {
      blocks: [
        {
          type: 'section',
          text: {
            type: 'plain_text',
            text: 'Command parameter must be provided.'
          }
        }
      ]
    }.to_json
  end
end
