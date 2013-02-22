# coding: utf-8
class Group < Base
  def save
    $redis.hmset key, *attributes.except('id').to_a.flatten
  end

  def add_user(user)
    $redis.multi do
      $redis.sadd users_key, user.key
      $redis.hset user.key, "group_id", attributes['id']
    end
  end

  def key
    "groups:#{@attributes['id']}"
  end

  def users_key
    "groups:#{@attributes['id']}:users"
  end
end
