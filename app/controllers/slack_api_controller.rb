# frozen_string_literal: true

# Handles API events from Slack
class SlackApiController < ApplicationController
  include ActionView::Helpers::NumberHelper

  SLACK_CURRENT_STATE_DATA_COMMAND = '/covid'

  before_action :validate_params
  before_action :validate_state_data

  def covid
    current_state_values = current_state_values(state_abbreviation_to_state(params[:text]))
    slack_response = render_slack_response(
      state_abbr_to_name(current_state_values[:state]),
      format_date_to_human_readable(current_state_values[:date].to_s),
      current_state_values[:positive],
      current_state_values[:positiveIncrease],
      current_state_values[:negative],
      current_state_values[:negativeIncrease],
      current_state_values[:death],
      current_state_values[:deathIncrease],
      calculate_day_over_day_change(current_state_values[:state], current_state_values[:date], :positiveIncrease),
      calculate_7_day_moving_average(current_state_values[:state], current_state_values[:date], :positiveIncrease)
    )
    render json: slack_response, status: :ok
  end

  def current_state_values(state_code)
    @current_state_values ||= covid_tracker.current_data_for_state(state_code)
  end

  def historic_state_data(state_code)
    @historic_state_data ||= covid_tracker.historic_data_for_state(state_code)
  end

  private

  def validate_params
    return false unless params.key?(:command)
    false unless params.key?(:text)
  end

  def validate_state_data
    return false unless params[:command] == SLACK_CURRENT_STATE_DATA_COMMAND
    false unless params[:text].split(/\s+/).length == 1
  end

  def covid_tracker
    @covid_tracker ||= CovidTracking.new
  end

  def us_country
    @us_country ||= Carmen::Country.coded('US')
  end

  def state_abbreviation_to_state(state_abbr)
    raise RuntimeError, 'Unidentifiable state code.' unless us_country.subregions.coded(state_abbr).present?
    state_abbr.downcase
  end

  def format_date_to_human_readable(date)
    Date.parse(date).to_formatted_s(:long_ordinal)
  end

  def state_abbr_to_name(state_abbr)
    us_country.subregions.coded(state_abbr).name
  end

  def calculate_day_over_day_change(state_code, date, metric)
    historic_state_data = historic_state_data(state_code)
    index = historic_state_data.find_index { |day_data| day_data[:date] == date }
    historic_state_data[index][metric] - historic_state_data[index + 1][metric]
  end

  def calculate_7_day_moving_average(state_code, date, metric)
    historic_state_data = historic_state_data(state_code)
    index = historic_state_data.find_index { |day_data| day_data[:date] == date }
    total = 0
    (index..index + 7).each do |i|
      total += historic_state_data[i][metric]
    end
    total / 7
  end

  def render_slack_response(
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
