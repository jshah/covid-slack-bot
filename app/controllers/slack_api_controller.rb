# frozen_string_literal: true

# Handles API events from Slack
class SlackApiController < ApplicationController
  def covid
    render status: 200, json: @controller.to_json
  end
end
