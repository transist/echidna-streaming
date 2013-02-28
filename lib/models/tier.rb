# coding: utf-8
require_relative 'base'

class Tier < Base
  def save
    $redis.hmset key, *attributes.slice('name').to_a.flatten
  end

  def add_city(city)
    $redis.sadd cities_key, city
  end

  def key
    "tiers/#{@attributes['id']}"
  end

  def cities_key
    "tiers/#{@attributes['id']}/cities"
  end
end
