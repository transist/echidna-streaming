# coding: utf-8
require 'bundler'
Bundler.require(:default)

Dir["lib/models/*.rb"].each { |file| require_relative "../#{file}" }

EM.synchrony do
  $redis = EventMachine::Synchrony::ConnectionPool.new(size: 4) do
    Redis.new driver: :synchrony
  end

  # publish add_user '{"id":"user-1","type":"tencent","birth_year":2000,"gender":"f","city":"shanghai"}'
  # publish add_group '{"id":"group-1","name":"Group 1"}'
  # publish add_user_to_group '{"group_id":"group-1","user_id":"user-1","user_type":"tencent"}'
  # publish add_tweet '{"user_id":"user-1","user_type":"tencent","text":"我是中国人","id":"abc","url":"http://t.qq.com/t/abc","timestamp":1361494534}'
  $redis.subscribe("add_user", "add_group", "add_user_to_group", "add_tweet", "add_word") do |on|
    on.message do |channel, msg|
      attributes = MultiJson.decode(msg)
      p attributes
      begin
        case channel
        when "add_user"
          User.new(attributes).save
        when "add_group"
          Group.new(attributes).save
        when "add_user_to_group"
          user = User.new("id" => attributes["user_id"], "type" => attributes["user_type"])
          Group.new("id" => attributes["group_id"]).add_user(user)
        when "add_tweet"
          group_id = User.new(attributes).group_id
          algorithm = RMMSeg::Algorithm.new(attributes['text'])
          segments = []
          loop do
            token = algorithm.next_token
            break if token.nil?
            $redis.publish "add_word", MultiJson.encode({"group_id" => group_id, "timestamp" => attributes['timestamp'], "word" => token.text})
          end
        when "add_word"
          Keyword.new(attributes).save
        end
      #rescue
        #puts $!.message
      end
    end
  end
end
