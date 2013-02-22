# coding: utf-8
class Source < Base
  def save
    $redis.hmset key, *attributes.slice('url').to_a.flatten
  end

  def url
    $redis.hget key, 'url'
  end

  def key
    "sources:#{@attributes['id']}"
  end
end
