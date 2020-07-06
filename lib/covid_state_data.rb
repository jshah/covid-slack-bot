# frozen_string_literal: true

# Generates COVID data for a state inside a slack block element.
class CovidStateData
  include ActionView::Helpers::NumberHelper

  attr_reader :command_parameter

  def self.call(command_parameter)
    new(command_parameter).call
  end

  def initialize(command_parameter)
    @command_parameter = command_parameter.downcase
  end

  def call
    return render_incorrect_parameter_length_response unless validate_command_parameter_length
    return render_invalid_state_response unless validate_command_parameter_is_valid_state

    current_state_data = current_state_data(command_parameter)
    state = current_state_data[:state]
    date = current_state_data[:date]
    historic_state_data = historic_state_data(command_parameter)

    render_state_covid_data_response(
      state_abbr_to_name(state),
      format_date_to_human_readable(date.to_s),
      current_state_data[:positive],
      current_state_data[:positiveIncrease],
      current_state_data[:negative],
      current_state_data[:negativeIncrease],
      current_state_data[:death],
      current_state_data[:deathIncrease],
      calculate_day_over_day_change(historic_state_data, date, :positiveIncrease),
      calculate_7_day_moving_average(historic_state_data, date, :positiveIncrease)
    )
  end

  private

  def validate_command_parameter_length
    command_parameter.split(/\s+/).length == 1
  end

  def validate_command_parameter_is_valid_state
    us_country.subregions.coded(command_parameter).present?
  end

  def covid_tracker_api
    @covid_tracker_api ||= CovidTrackingApi.new
  end

  def current_state_data(state_code)
    covid_tracker_api.current_data_for_state(state_code)
  end

  def historic_state_data(state_code)
    covid_tracker_api.historic_data_for_state(state_code)
  end

  def us_country
    @us_country ||= Carmen::Country.coded('US')
  end

  def state_abbr_to_name(state_abbr)
    us_country.subregions.coded(state_abbr).name
  end

  def format_date_to_human_readable(date)
    Date.parse(date).to_formatted_s(:long_ordinal)
  end

  def calculate_day_over_day_change(historic_state_data, date, metric)
    data_for_date = historic_state_data.find_index { |day_data| day_data[:date] == date }
    historic_state_data[data_for_date][metric] - historic_state_data[data_for_date + 1][metric]
  end

  def calculate_7_day_moving_average(historic_state_data, date, metric)
    index = historic_state_data.find_index { |day_data| day_data[:date] == date }
    total = 0
    (index..index + 7).each do |i|
      total += historic_state_data[i][metric]
    end
    total / 7
  end

  def render_incorrect_parameter_length_response
    {
      blocks: [
        {
          type: 'section',
          text: {
            type: 'plain_text',
            text: 'Too many parameters passed into command.'
          }
        }
      ]
    }.to_json
  end

  def render_invalid_state_response
    {
      blocks: [
        {
          type: 'section',
          text: {
            type: 'plain_text',
            text: 'Could not recognize state code.'
          }
        }
      ]
    }.to_json
  end

  def render_state_covid_data_response(
    state,
    date,
    total_positive,
    daily_positive_difference,
    total_negative,
    daily_negative_difference,
    total_deaths,
    daily_death_difference,
    positive_cases_dod,
    positive_cases_7_day_moving_average
  )
    {
      response_type: 'in_channel',
      blocks: [
        {
          type: 'section',
          text: {
            type: 'mrkdwn',
            text: "The most recent COVID data for *#{state}*. Data as of *#{date}*."
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
              text: number_with_delimiter(total_positive).to_s
            },
            {
              type: 'plain_text',
              text: number_with_delimiter(daily_positive_difference).to_s
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
              text: number_with_delimiter(total_negative).to_s
            },
            {
              type: 'plain_text',
              text: number_with_delimiter(daily_negative_difference).to_s
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
              text: number_with_delimiter(total_deaths).to_s
            },
            {
              type: 'plain_text',
              text: number_with_delimiter(daily_death_difference).to_s
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
              text: '*Rate of Positive Cases (Day/Day Change)*'
            },
            {
              type: 'mrkdwn',
              text: '*Positive Cases (7-Day Moving Average)*'
            },
            {
              type: 'plain_text',
              text: number_with_delimiter(positive_cases_dod).to_s
            },
            {
              type: 'plain_text',
              text: number_with_delimiter(positive_cases_7_day_moving_average).to_s
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
              text: 'Data provided by https://covidtracking.com/.'
            }
          ]
        }
      ]
    }.to_json
  end
end
