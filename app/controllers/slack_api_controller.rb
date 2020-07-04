# frozen_string_literal: true

# Handles API events from Slack
class SlackApiController < ApplicationController
  def covid
    puts "headers=#{request.headers}"
    puts "body=#{request.body}"
    render json: {}, status: :ok
  end
end
