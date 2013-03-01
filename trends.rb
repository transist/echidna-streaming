# coding: utf-8
streaming_env = ENV['ECHIDNA_STREAMING_ENV'] || "development"
streaming_ip = ENV['ECHIDNA_STREAMING_IP'] || "0.0.0.0"
streaming_port = ENV['ECHIDNA_STREAMING_PORT'] || "9001"
streaming_daemon = ENV['ECHIDNA_STREAMING_DAEMON'] == "true"
$redis_host = ENV['ECHIDNA_REDIS_HOST'] || "127.0.0.1"
$redis_port = ENV['ECHIDNA_REDIS_PORT'] || "6379"
$redis_namespace = ENV['ECHIDNA_REDIS_NAMESPACE'] || "e:d"

ARGV.replace ["-e", streaming_env, "-a", streaming_ip, "-p", streaming_port]
ARGV << "-d" if streaming_daemon
ARGV << '-sv' if streaming_env == 'development'

require 'bundler'
Bundler.require(:default, streaming_env.to_sym)
require 'goliath'

require 'syslog'
$logger = Syslog.open("streaming trends", Syslog::LOG_PID | Syslog::LOG_CONS, Syslog::LOG_LOCAL3)

Dir["lib/helpers/*.rb"].each { |file| require_relative file }
Dir["lib/models/*.rb"].each { |file| require_relative file }

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
