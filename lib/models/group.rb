# coding: utf-8
require_relative 'base'
require 'set'

class Group < Base
  def self.find_group_ids(gender, birth_year, city)
    [self.find_tier_group(gender, birth_year, city), self.find_city_group(gender, birth_year, city)].compact
  end

  def self.find_tier_group(gender, birth_year, city)
    tier_id = City.new("name" => city)["tier_id"] || "tier-other"
    $redis.smembers(self.key).each do |group_key|
      group = Group.new_with_key(group_key, $redis.hgetall(group_key))
      if group['gender'] == gender && birth_year.to_i >= group['start_birth_year'].to_i && birth_year.to_i <= group['end_birth_year'].to_i && tier_id == group['tier_id']
        return group.key.split('/').last
      end
    end
    nil
  end

  def self.find_city_group(gender, birth_year, city)
    $redis.smembers(self.key).each do |group_key|
      group = Group.new_with_key(group_key, $redis.hgetall(group_key))
      if group['gender'] == gender && birth_year.to_i >= group['start_birth_year'].to_i && birth_year.to_i <= group['end_birth_year'].to_i && city == group['city']
        return group.key.split('/').last
      end
    end
    nil
  end

  def save
    super
    $redis.sadd self.class.key, self.key
  end

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

  def self.key
    "groups"
  end
end
