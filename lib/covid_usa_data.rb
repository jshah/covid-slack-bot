# frozen_string_literal: true

# Generates COVID data for the United States inside a slack block element.
class CovidUsaData
  include ActionView::Helpers::NumberHelper
  include CovidDataHelpers

  def self.call
    new.call
  end

  def call
    current_us_data = current_data_for_usa.first
    date = current_us_data[:date]
    historic_us_data = historic_data_for_usa
    render_state_covid_data_response(
      format_date_to_human_readable(date.to_s),
      current_us_data[:positive],
      current_us_data[:positiveIncrease],
      current_us_data[:negative],
      current_us_data[:negativeIncrease],
      current_us_data[:death],
      current_us_data[:deathIncrease],
      calculate_day_over_day_change(historic_us_data, date, :positiveIncrease),
      calculate_7_day_moving_average(historic_us_data, date, :positiveIncrease),
      calculate_day_over_day_change(historic_us_data, date, :negativeIncrease),
      calculate_7_day_moving_average(historic_us_data, date, :negativeIncrease),
      calculate_day_over_day_change(historic_us_data, date, :deathIncrease),
      calculate_7_day_moving_average(historic_us_data, date, :deathIncrease)
    )
  end

  private

  def covid_tracker_api
    @covid_tracker_api ||= CovidTrackingApi.new
  end

  def current_data_for_usa
    covid_tracker_api.current_data_for_usa
  end

  def historic_data_for_usa
    covid_tracker_api.historic_data_for_usa
  end

  def render_state_covid_data_response(
    date,
    total_positive,
    daily_positive_difference,
    total_negative,
    daily_negative_difference,
    total_deaths,
    daily_death_difference,
    positive_cases_dod,
    positive_cases_7_day_moving_average,
    negative_cases_dod,
    negative_cases_7_day_moving_average,
    deaths_dod,
    deaths_7_day_moving_average
  )
    {
      response_type: 'in_channel',
      blocks: [
        {
          type: 'section',
          text: {
            type: 'mrkdwn',
            text: "The most recent COVID data for the *United States*. Data as of *#{date}*."
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
              text: number_with_delimiter(total_positive)
            },
            {
              type: 'plain_text',
              text: number_with_delimiter(daily_positive_difference)
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
              text: number_with_delimiter(total_negative)
            },
            {
              type: 'plain_text',
              text: number_with_delimiter(daily_negative_difference)
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
              text: number_with_delimiter(total_deaths)
            },
            {
              type: 'plain_text',
              text: number_with_delimiter(daily_death_difference)
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
              text: add_sign_and_delimiter(positive_cases_dod)
            },
            {
              type: 'plain_text',
              text: number_with_delimiter(positive_cases_7_day_moving_average)
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
              text: add_sign_and_delimiter(negative_cases_dod)
            },
            {
              type: 'plain_text',
              text: number_with_delimiter(negative_cases_7_day_moving_average)
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
              text: add_sign_and_delimiter(deaths_dod)
            },
            {
              type: 'plain_text',
              text: number_with_delimiter(deaths_7_day_moving_average)
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
  end
end
