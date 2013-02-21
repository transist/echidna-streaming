# coding: utf-8
class Group < Base
  def add_user(user)
    $redis.multi do
      $redis.sadd users_key, user.key
      $redis.hset user.key, "group_key", self.key
    end
  end

  def key
    "groups:#{@attributes['name']}"
  end

  def users_key
    "groups:#{@attributes['name']}:users"
  end
end
