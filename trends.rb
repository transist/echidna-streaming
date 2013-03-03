# coding: utf-8
echidna_env = ENV['ECHIDNA_ENV'] || "development"
streaming_ip = ENV['ECHIDNA_STREAMING_IP'] || "0.0.0.0"
streaming_port = ENV['ECHIDNA_STREAMING_PORT'] || "9001"
streaming_daemon = ENV['ECHIDNA_STREAMING_DAEMON'] == "true"

ARGV.replace ["-e", echidna_env, "-a", streaming_ip, "-p", streaming_port]
ARGV << "-d" if streaming_daemon
ARGV << '-sv' if echidna_env == 'development'

require 'bundler'
Bundler.require(:default, echidna_env)
require 'goliath'

class Trends < Goliath::API
  use Goliath::Rack::Params

  def response(env)
    $logger.notice("#{env["REQUEST_PATH"]} api received: #{params}")
    case env["REQUEST_PATH"]
    when "/"
      keywords = Group.new("id" => params["group_id"]).trends(params["interval"], params["start_timestamp"], params["end_timestamp"])
      [200, {}, MultiJson.encode(keywords)]
    when "/get_group_ids"
      group_ids = Group.find_group_ids(params["gender"], params["birth_year"], params["city"])
      [200, {}, MultiJson.encode("ids" => group_ids)]
    end
  end
end
$logger.notice("streaming listen on #{streaming_ip}:#{streaming_port}")
