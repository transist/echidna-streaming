# coding: utf-8
require_relative 'base'

class Tier < Base
  def self.all
    $redis.smembers(self.key).map do |tier_key|
      tier_id = tier_key.split('/').last
      $redis.hgetall(tier_key).merge(
        "id" => tier_id,
        "cities" => Tier.new("id" => tier_id).cities
      )
    end
  end

  def save
    super
    $redis.sadd self.class.key, self.key
  end

  def add_city(city)
    City.new("name" => city)["tier_id"] = @attributes["id"]
    $redis.sadd cities_key, city
  end

  def remove_city(city)
    City.new("name" => city)["tier_id"] = nil
    $redis.srem cities_key, city
  end

  def cities
    $redis.smembers cities_key
  end

  def cities_key
    "tiers/#{@attributes['id']}/cities"
  end

  def self.key
    "tiers"
  end
end
