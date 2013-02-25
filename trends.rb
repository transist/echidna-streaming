# coding: utf-8
streaming_env = ENV['ECHIDNA_STREAMING_ENV'] || "development"
streaming_ip = ENV['ECHIDNA_STREAMING_IP'] || "0.0.0.0"
streaming_port = ENV['ECHIDNA_STREAMING_PORT'] || '9000'
$redis_host = ENV['ECHIDNA_REDIS_HOST'] || "127.0.0.1"
$redis_port = ENV['ECHIDNA_REDIS_PORT'] || "6379"
$redis_namespace = ENV['ECHIDNA_REDIS_NAMESPACE'] || "e:d"

ARGV = ["-e", streaming_env, "-a", streaming_ip, "-p", streaming_port]

require 'bundler'
Bundler.require(:default, streaming_env.to_sym)
require 'goliath'

Dir["lib/helpers/*.rb"].each { |file| require_relative file }
Dir["lib/models/*.rb"].each { |file| require_relative file }

class Trends < Goliath::API
  use Goliath::Rack::Params

  def response(env)
    logger.info "Received: #{params}"
    keywords = Group.new("id" => params["group_id"]).trends(params["interval"], params["start_timestamp"], params["end_timestamp"])
    [200, {}, MultiJson.encode(keywords)]
  end
end
