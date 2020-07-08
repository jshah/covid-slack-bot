# frozen_string_literal: true

# Handles API events from Slack
class SlackApiController < ApplicationController
  before_action :verify_slack_request_authenticity, except: [:slack_oauth]
  before_action :validate_command, only: [:covid_state_data, :covid_usa_data]
  before_action :validate_text, only: [:covid_state_data]

  def covid_state_data
    render json: CovidStateData.call(params[:text]), status: :ok
  end

  def covid_usa_data
    render json: CovidUsaData.call, status: :ok
  end

  def slack_oauth
    SlackOauthExchangeApi.exchange_code_for_access_token(params[:code])
    success_html = '<html><body><h1>Success!</h1></body></html>'.html_safe
    render html: success_html, status: :ok
  end

  private

  def gen_hash(secret, data)
    OpenSSL::HMAC.hexdigest('sha256', secret, data)
  end

  # https://api.slack.com/authentication/verifying-requests-from-slack
  def verify_slack_request_authenticity
    return true if Rails.env.development?

    slack_request_timestamp = request.headers['X-Slack-Request-Timestamp']
    if (Time.now.to_i - slack_request_timestamp.to_i).abs > 60 * 5
      return render json: { error: 'Request too old.' }, status: :bad_request
    end

    sig_basestring = 'v0:' + slack_request_timestamp.to_s + ':' + request.body.read
    my_signature = 'v0=' + gen_hash(ENV['SLACK_SIGNING_SECRET'], sig_basestring)
    slack_signature = request.headers['X-Slack-Signature']

    return true if my_signature == slack_signature
    render json: { error: 'Could not verify slack authenticity.' }, status: :bad_request
  end

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
