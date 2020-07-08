# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CovidUsaData do
  describe '.call' do
    let(:covid_current_usa_data) do
      [{
        state: 'CA',
        date: 20_200_704,
        positive: 100,
        positiveIncrease: 5,
        negative: 2000,
        negativeIncrease: 200,
        death: 50,
        deathIncrease: 1
      }]
    end
    let(:mock_current_usa_data) do
      {
        state: 'CA',
        date: 20_200_704,
        positive: 200,
        positiveIncrease: 10,
        negative: 4000,
        negativeIncrease: 400,
        death: 100,
        deathIncrease: 2
      }
    end
    let(:covid_historical_usa_data) do
      [
        covid_current_usa_data.first,
        mock_current_usa_data,
        covid_current_usa_data.first,
        covid_current_usa_data.first,
        mock_current_usa_data,
        mock_current_usa_data,
        mock_current_usa_data,
        mock_current_usa_data,
        mock_current_usa_data,
        mock_current_usa_data
      ]
    end
    let(:covid_tracker) { CovidTrackingApi.new }

    before do
      allow(CovidTrackingApi).to receive(:new).and_return(covid_tracker)
      allow(covid_tracker).to receive(:current_data_for_usa).and_return(covid_current_usa_data)
      allow(covid_tracker).to receive(:historic_data_for_usa).and_return(covid_historical_usa_data)
    end

    it 'renders correct slack block' do
      expected = {
        response_type: 'in_channel',
        blocks: [
          {
            type: 'section',
            text: {
              type: 'mrkdwn',
              text: 'The most recent COVID data for the *United States*. Data as of *July 4th, 2020*.'
            }
          },
          {
            type: 'section',
            fields: [
              {
                type: 'mrkdwn',
                text: '*Total Positive Cases*'
              },
              {
                type: 'mrkdwn',
                text: '*New Positive Cases*'
              },
              {
                type: 'plain_text',
                text: '100'
              },
              {
                type: 'plain_text',
                text: '5'
              }
            ]
          },
          {
            type: 'section',
            fields: [
              {
                type: 'mrkdwn',
                text: '*Total Negative Cases*'
              },
              {
                type: 'mrkdwn',
                text: '*New Negative Cases*'
              },
              {
                type: 'plain_text',
                text: '2,000'
              },
              {
                type: 'plain_text',
                text: '200'
              }
            ]
          },
          {
            type: 'section',
            fields: [
              {
                type: 'mrkdwn',
                text: '*Total Deaths*'
              },
              {
                type: 'mrkdwn',
                text: '*New Deaths*'
              },
              {
                type: 'plain_text',
                text: '50'
              },
              {
                type: 'plain_text',
                text: '1'
              }
            ]
          },
          {
            type: 'divider'
          },
          {
            type: 'section',
            fields: [
              {
                type: 'mrkdwn',
                text: '*New Positive Cases (Daily Change)*'
              },
              {
                type: 'mrkdwn',
                text: '*Positive Cases (7-Day Moving Average)*'
              },
              {
                type: 'plain_text',
                text: '-5'
              },
              {
                type: 'plain_text',
                text: '8'
              }
            ]
          },
          {
            type: 'section',
            fields: [
              {
                type: 'mrkdwn',
                text: '*New Negative Cases (Daily Change)*'
              },
              {
                type: 'mrkdwn',
                text: '*Negative Cases (7-Day Moving Average)*'
              },
              {
                type: 'plain_text',
                text: '-200'
              },
              {
                type: 'plain_text',
                text: '314'
              }
            ]
          },
          {
            type: 'section',
            fields: [
              {
                type: 'mrkdwn',
                text: '*New Deaths (Daily Change)*'
              },
              {
                type: 'mrkdwn',
                text: '*Deaths (7-Day Moving Average)*'
              },
              {
                type: 'plain_text',
                text: '-1'
              },
              {
                type: 'plain_text',
                text: '2'
              }
            ]
          },
          {
            type: 'divider'
          },
          {
            type: 'context',
            elements: [
              {
                type: 'mrkdwn',
                text: 'Data provided by https://covidtracking.com/'
              }
            ]
          }
        ]
      }.to_json
      expect(CovidUsaData.call).to eq(expected)
    end
  end
end
