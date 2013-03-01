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

p APP_ROOT

Dir[APP_ROOT.join("lib/helpers/*.rb")].each { |file| require_relative file }
Dir[APP_ROOT.join("lib/models/*.rb")].each { |file| require_relative file }

RMMSeg::Dictionary.load_dictionaries
$logger.notice("load dictionaries")

EM.synchrony do
  $subscribe_redis = Redis::Namespace.new(redis_namespace, redis: Redis.new(host: redis_host, port: redis_port, driver: "synchrony"))
  $redis = Redis::Namespace.new(redis_namespace, redis: Redis.new(host: redis_host, port: redis_port, driver: "hiredis"))
  $logger.notice("connect to redis: #{redis_host}:#{redis_port}/#{redis_namespace}")

  # publish e:d:add_user '{"id":"user-1","type":"tencent","birth_year":2000,"gender":"f","city":"shanghai"}'
  # publish e:d:add_group '{"id":"group-1","name":"Group 1"}'
  # publish e:d:add_user_to_group '{"group_id":"group-1","user_id":"user-1","user_type":"tencent"}'
  # publish e:d:add_tweet '{"user_id":"user-1","user_type":"tencent","text":"我是中国人","id":"abc","url":"http://t.qq.com/t/abc","timestamp":1361494534}'
  $subscribe_redis.subscribe("add_user", "add_group", "add_user_to_group", "add_tweet", "add_word") do |on|
    on.message do |channel, msg|
      $logger.notice("redis receive message: #{msg} on channel: #{channel}")
      attributes = MultiJson.decode(msg)
      begin
        case channel.split(":").last
        when "add_user"
          User.new(attributes).save
        when "add_group"
          Group.new(attributes).save
        when "add_user_to_group"
          user = User.new("id" => attributes["user_id"], "type" => attributes["user_type"])
          Group.new("id" => attributes["group_id"]).add_user(user)
        when "add_tweet"
          Source.new(attributes).save
          group_id = User.new("id" => attributes["user_id"], "type" => attributes["user_type"])['group_id']
          algorithm = RMMSeg::Algorithm.new(attributes['text'])
          segments = []
          loop do
            token = algorithm.next_token
            break if token.nil?
            $redis.publish "add_word", '{}'
            unless $redis.sismember "stopwords", token.text
              $redis.rpush "word", MultiJson.encode(
                "group_id" => group_id,
                "timestamp" => attributes['timestamp'],
                "source_id" => attributes['id'],
                "word" => token.text
              )
            end
          end
        when "add_word"
          word_attributes = MultiJson.decode($redis.lpop("word"))
          Keyword.new(word_attributes).save
        end
      rescue
        $logger.notice("error: #{$!.message}")
      end
    end
  end
end
