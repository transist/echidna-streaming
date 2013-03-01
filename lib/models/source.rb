# coding: utf-8
require_relative 'base'

class Source < Base
  def url
    $redis.hget key, 'url'
  end

  def save
    super
    $redis.sadd sources_key, @attributes['id']
  end

  def exist?
    $redis.sismember sources_key, @attributes['id']
  end

  def sources_key
    "sources"
  end
end
