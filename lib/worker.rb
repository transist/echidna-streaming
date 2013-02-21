# coding: utf-8
require 'bundler'
Bundler.require(:default)

Dir["lib/models/*.rb"].each { |file| require_relative "../#{file}" }

EM.synchrony do
  $redis = EventMachine::Synchrony::ConnectionPool.new(size: 4) do
    Redis.new driver: :synchrony
  end

  $redis.subscribe("tencent_weibo_users", "tencent_weibo_tweets") do |on|
    on.message do |channel, msg|
      case channel
      when "tencent_weibo_users"
        user_attributes = MultiJson.decode(msg)
        User.new(user_attributes).save
      when "tencent_weibo_tweets"
        algorithm = RMMSeg::Algorithm.new(msg)
        segments = []
        loop do
          token = algorithm.next_token
          break if token.nil?
          segments << token.text
        end
      end
    end
  end
end
