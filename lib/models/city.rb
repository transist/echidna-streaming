# coding: utf-8
require_relative 'base'

class City < Base
  def save
    $redis.hmset key, *attributes.slice('tier_id').to_a.flatten
  end

  def key
    "city/#{@attributes['name']}"
  end
end
