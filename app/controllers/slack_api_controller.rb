class SlackApiController < ApplicationController
  def covid
    render status: 200, json: @controller.to_json
  end
end
