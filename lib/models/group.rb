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

  def trends(interval, start_time_str, end_time_str, limit=100)
    start_timestamp = Timestamp.new(start_time_str, format: 'plain').send("to_#{interval}")
    end_timestamp = Timestamp.new(end_time_str, format: 'plain').send("to_#{interval}")
    interval_timestamp = 1.send(interval)

    trends = {}
    while (start_timestamp <= end_timestamp)
      timestamp = Timestamp.new(Time.at(start_timestamp.to_i)).send("to_formatted_#{interval}")
      trends[timestamp] ||= []
      result = $redis.zrevrange "groups/#{@attributes['id']}/#{interval}/#{start_timestamp}/keywords", 0, limit - 1, with_scores: true
      result.each do |word, count|
        source_id = $redis.get("groups/#{@attributes['id']}/#{interval}/#{start_timestamp}/#{word}/source_id")
        source_url = Source.new("id" => source_id).url
        trends[timestamp] << {"word" => word, "count" => count.to_i, "source" => source_url}
      end
      start_timestamp += interval_timestamp
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
