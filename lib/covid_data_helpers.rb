# frozen_string_literal: true

# Helper methods shared across COVID data classes
module CovidDataHelpers
  def format_date_to_human_readable(date)
    Date.parse(date).to_formatted_s(:long_ordinal)
  end

  def add_sign_and_delimiter(num)
    sign = num.positive? ? '+' : ''
    "#{sign}#{number_with_delimiter(num)}"
  end

  def calculate_day_over_day_change(covid_data, date, metric)
    data_for_date = covid_data.find_index { |day_data| day_data[:date] == date }
    covid_data[data_for_date][metric] - covid_data[data_for_date + 1][metric]
  end

  def calculate_7_day_moving_average(covid_data, date, metric)
    index = covid_data.find_index { |day_data| day_data[:date] == date }
    total = 0
    (index...index + 7).each do |i|
      total += covid_data[i][metric]
    end
    (total / 7.0).round
  end
end
