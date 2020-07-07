# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SlackApiController do
  let(:time) { Time.zone.local(2020, 7, 6) }

  def authentic_slack_request
    headers = { 'X-Slack-Request-Timestamp': time.to_i, 'X-Slack-Signature': 'v0=abc123' }
    request.headers.merge!(headers)
    allow(OpenSSL::HMAC).to receive(:hexdigest).and_return('abc123')
  end

  before do
    travel_to time
    authentic_slack_request
  end

  describe 'POST covid_state_data' do
    context 'validations' do
      it 'validates command is present' do
        post :covid_state_data, params: { text: 'CA' }
        expected = {
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
        expect(response.body).to eq(expected)
      end

      it 'validates command parameter is present' do
        post :covid_state_data, params: { command: '/covid_state_data' }
        expected = {
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
        expect(response.body).to eq(expected)
      end

      context '#verify_slack_request_authenticity' do
        it 'renders request too old' do
          headers = { 'X-Slack-Request-Timestamp': time.to_i - 600 }
          request.headers.merge!(headers)
          response = post :covid_state_data, params: {}
          expect(response.body).to eq({ error: 'Request too old.' }.to_json)
        end

        it 'renders could not verify slack authenticity' do
          headers = { 'X-Slack-Request-Timestamp': time.to_i, 'X-Slack-Signature': 'v0=abc124' }
          request.headers.merge!(headers)
          response = post :covid_state_data, params: {}
          expect(response.body).to eq({ error: 'Could not verify slack authenticity.' }.to_json)
        end
      end
    end

    context 'calls CovidStateData' do
      specify do
        expect(CovidStateData).to receive(:call).with('CA')
        post :covid_state_data, params: { command: '/covid_state_data', text: 'CA' }
      end
    end
  end
end
