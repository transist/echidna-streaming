# coding: utf-8
require_relative 'base'
require 'set'

class Group < Base
  def trends(interval, start_timestamp, end_timestamp, limit=100)
    keys = $redis.zrangebyscore "groups/#{@attributes['id']}/#{interval}/keywords", Timestamp.new(start_timestamp).send("to_#{interval}_int"), Timestamp.new(end_timestamp).send("to_#{interval}_int")
    trends = {}
    keys.each do |key|
      count = $redis.get(key).to_i
      _, _, _, timestamp, word = key.split('/')
      source_url = Source.new("id" => $redis.get(key + "/source_id")).url
      trends[timestamp] ||= []
      trends[timestamp] << {"word" => word, "count" => count, "source" => source_url}
    end
    trends.each do |timestamp, keywords|
      keywords.sort_by! { |hash| -hash["count"] }
    end
    trends
  end

  def add_user(user)
    $redis.multi do
      $redis.sadd users_key, user.key
      $redis.hset user.key, "group_id", attributes['id']
    end
  end

  def users_key
    "groups/#{@attributes['id']}/users"
  end
end
