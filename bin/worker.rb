# coding: utf-8
require 'bundler'
Bundler.require(:default, ENV['ECHIDNA_ENV'] || "development")

# redis-cli lpush e:flyerhzm:d:streaming/messages '{"type":"add_user","body":{"id":"user-1","type":"tencent","birth_year":2000,"gender":"f","city":"shanghai"}}'
# redis-cli lpush e:flyerhzm:d:streaming/messages '{"type":"add_user_to_group","body":{"group_id":"group-1","user_id":"user-1","user_type":"tencent"}}'
# redis-cli lpush e:flyerhzm:d:streaming/messages '{"type":"add_tweet","body":{"user_id":"user-1","user_type":"tencent","text":"我是中国人","id":"abc","url":"http://t.qq.com/t/abc","timestamp":1361494534}}'
while true
  raw_message = $redis.blpop "streaming/messages", 0
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
      $redis.rpush "dicts/messages", MultiJson.encode(
        type: "segment",
        body: message["body"].slice("text", "timestamp").merge(group_id: group_id, source_id: message["body"]["id"])
      )
    end
  when "add_words"
    message["body"].delete("words").each do |word|
      Keyword.new(message["body"].merge("word" => word)).save
    end
    result = Crontab.new("timestamp" => message["body"]["timestamp"], "group_id" => message["body"]["group_id"]).fetch_and_save
    $redis.rpush "api/messages/#{message['body']['group_id']}/trends", MultiJson.encode(result)
    $redis.ltrim "api/messages/#{message['body']['group_id']}/trends", 0, 999
  end
end
