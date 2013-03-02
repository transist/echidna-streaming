# coding: utf-8
streaming_env = ENV['ECHIDNA_STREAMING_ENV'] || "development"
redis_host = ENV['ECHIDNA_REDIS_HOST'] || "127.0.0.1"
redis_port = ENV['ECHIDNA_REDIS_PORT'] || "6379"
redis_namespace = ENV['ECHIDNA_REDIS_NAMESPACE'] || "e:d"

require 'pathname'
APP_ROOT = Pathname.new(File.expand_path('../..', __FILE__))

require 'bundler'
Bundler.require(:default, streaming_env)
require 'syslog'
$logger = Syslog.open("streaming worker", Syslog::LOG_PID | Syslog::LOG_CONS, Syslog::LOG_LOCAL3)

Dir[APP_ROOT.join("lib/helpers/*.rb")].each { |file| require_relative file }
Dir[APP_ROOT.join("lib/models/*.rb")].each { |file| require_relative file }

$redis = Redis::Namespace.new(redis_namespace, redis: Redis.new(host: redis_host, port: redis_port, driver: "hiredis"))
$logger.notice("connect to redis: #{redis_host}:#{redis_port}/#{redis_namespace}")

# redis-cli lpush e:d:streaming/messages '{"type":"add_user","body":{"id":"user-1","type":"tencent","birth_year":2000,"gender":"f","city":"shanghai"}}'
# redis-cli lpush e:d:streaming/messages '{"type":"add_user_to_group","body":{"group_id":"group-1","user_id":"user-1","user_type":"tencent"}}'
# redis-cli lpush e:d:streaming/messages '{"type":"add_tweet","body":{"user_id":"user-1","user_type":"tencent","text":"我是中国人","id":"abc","url":"http://t.qq.com/t/abc","timestamp":1361494534}}'
while true
  raw_message = $redis.brpop "streaming/messages", 0
  $logger.notice("streaming receive message: #{raw_message}")
  message = MultiJson.decode raw_message.last
  case message["type"]
  when "add_user"
    User.new(message["body"]).save
  when "add_user_to_group"
    user = User.new("id" => message["body"]["user_id"], "type" => message["body"]["user_type"])
    Group.new("id" => message["body"]["group_id"]).add_user(user)
  when "add_tweet"
    source = Source.new(message["body"])
    unless source.exist?
      source.save
      group_id = User.new("id" => message["body"]["user_id"], "type" => message["body"]["user_type"])['group_id']
      $redis.lpush "dicts/messages", MultiJson.encode(
        type: "segment",
        body: message["body"].slice("text", "timestamp").merge(group_id: group_id, source_id: message["body"]["id"])
      )
    end
  when "add_words"
    message["body"].delete("words").each do |word|
      Keyword.new(message["body"].merge("word" => word)).save
    end
  end
end
