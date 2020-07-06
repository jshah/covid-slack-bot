# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SlackApiController do
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
    end

    context 'calls CovidStateData' do
      specify do
        expect(CovidStateData).to receive(:call).with('CA')
        post :covid_state_data, params: { command: '/covid_state_data', text: 'CA' }
      end
    end
  end
end
