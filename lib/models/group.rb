# coding: utf-8
class Group < Base
  def add_user(user)
    $redis.sadd key, user.key
  end

  def key
    "groups:#{@attributes['name']}"
  end
end
