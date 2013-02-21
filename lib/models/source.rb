# coding: utf-8
class Source < Base
  def save
    $redis.hmset key, *attributes.except('id').to_a.flatten
  end

  def key
    "sources:#{@attributes['id']}"
  end
end
