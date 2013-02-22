# coding: utf-8
require 'bundler'
Bundler.require(:default)

Dir["lib/models/*.rb"].each { |file| require_relative file }

class Trends < Goliath::API
  use Goliath::Rack::Params

  def response(env)
    logger.info "Received: #{params}"
    keywords = Group.new("id" => params["group_id"]).trends(params["interval"], params["start_timestamp"], params["end_timestamp"])
    [200, {}, MultiJson.encode(keywords)]
  end
end
