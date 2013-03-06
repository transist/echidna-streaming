# coding: utf-8
echidna_env = ENV['ECHIDNA_ENV'] || "development"

require 'bundler'
Bundler.require(:default, echidna_env)
require 'goliath'

streaming_ip = ENV['ECHIDNA_STREAMING_IP'] || "0.0.0.0"
streaming_port = app_port('streaming')
streaming_daemon = ENV['ECHIDNA_STREAMING_DAEMON'] == "true"

ARGV.replace ["-e", echidna_env, "-a", streaming_ip, "-p", streaming_port]
ARGV << "-d" if streaming_daemon
ARGV << '-sv' if echidna_env == 'development'

class Trends < Goliath::API
  use Goliath::Rack::Params

  def response(env)
    $logger.notice("#{env["REQUEST_PATH"]} api received: #{params}")
    case env["REQUEST_PATH"]
    when "/"
      start_timestamp = Time.parse(params["start_time"]).to_i
      end_timestamp = Time.parse(params["end_time"]).to_i
      keywords = Group.new("id" => params["group_id"]).trends(params["interval"], start_timestamp, end_timestamp)
      [200, {}, MultiJson.encode(keywords)]
    when "/tiers"
      tiers = Tier.all
      [200, {}, MultiJson.encode(tiers)]
    when "/groups"
      groups = Group.all
      [200, {}, MultiJson.encode(groups)]
    when "/group_id" # for echidna-api
      response_body = $cacher.fetch "cache/#{params.slice('gender', 'age_range', 'tier_id').values.join('/')}/group_id", :expires_in => 86400 do
        group_id = Group.find_tier_group_id(params["gender"], params["age_range"], params["tier_id"])
        response_body = MultiJson.encode("id" => group_id)
      end
      [200, {}, response_body]
    when "/get_group_ids" # for echidna-spider
      response_body = $cacher.fetch "cache/#{params.slice('gender', 'birth_year', 'city').values.join('/')}/group_ids", :expires_in => 86400 do
        group_ids = Group.find_group_ids(params["gender"], params["birth_year"], params["city"])
        MultiJson.encode("ids" => group_ids)
      end
      [200, {}, response_body]
    end
  end
end
$logger.notice("streaming listen on #{streaming_ip}:#{streaming_port}")
