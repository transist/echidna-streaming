# coding: utf-8
class User < Base
  def save
    $redis.hmset key, *attributes.except('type', 'id').to_a.flatten
  end

  def group_id
    $redis.hget key, "group_id"
  end

  def key
    "users:#{@attributes['type']}:#{@attributes['id']}"
  end
end
