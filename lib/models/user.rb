# coding: utf-8
require_relative 'base'

class User < Base
  def save
    $redis.hmset key, *attributes.slice('birth_year', 'gender', 'city').to_a.flatten
  end

  def group_id
    $redis.hget key, "group_id"
  end

  def key
    "users:#{@attributes['type']}:#{@attributes['id']}"
  end
end
