# coding: utf-8
require 'bundler'
ENV['ECHIDNA_ENV'] ||= "development"
Bundler.require(:default, ENV['ECHIDNA_ENV'])

Dir["lib/helpers/*.rb"].each { |file| require_relative "../#{file}" }
Dir["lib/models/*.rb"].each { |file| require_relative "../#{file}" }

RMMSeg::Dictionary.load_dictionaries

EM.synchrony do
  redis_config = YAML.load_file("config/redis.yml")[ENV['ECHIDNA_ENV']]
  namespace = redis_config.delete("namespace")
  $subscribe_redis = Redis::Namespace.new(namespace, redis: Redis.new(redis_config.merge(driver: "synchrony")))
  $redis = Redis::Namespace.new(namespace, redis: Redis.new(redis_config.merge(driver: "hiredis")))

  # publish e:d:add_user '{"id":"user-1","type":"tencent","birth_year":2000,"gender":"f","city":"shanghai"}'
  # publish e:d:add_group '{"id":"group-1","name":"Group 1"}'
  # publish e:d:add_user_to_group '{"group_id":"group-1","user_id":"user-1","user_type":"tencent"}'
  # publish e:d:add_tweet '{"user_id":"user-1","user_type":"tencent","text":"我是中国人","id":"abc","url":"http://t.qq.com/t/abc","timestamp":1361494534}'
  $subscribe_redis.subscribe("add_user", "add_group", "add_user_to_group", "add_tweet", "add_word") do |on|
    on.message do |channel, msg|
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
          group_id = User.new("id" => attributes["user_id"], "type" => attributes["user_type"]).group_id
          algorithm = RMMSeg::Algorithm.new(attributes['text'])
          segments = []
          loop do
            token = algorithm.next_token
            break if token.nil?
            $redis.publish "add_word", '{}'
            $redis.rpush "word", MultiJson.encode({"group_id" => group_id, "timestamp" => attributes['timestamp'], "source_id" => attributes['id'], "word" => token.text})
          end
        when "add_word"
          word_attributes = MultiJson.decode($redis.lpop("word"))
          Keyword.new(word_attributes).save
        end
      rescue
        puts $!.message
      end
    end
  end
end
