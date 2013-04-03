# coding: utf-8
require_relative 'base'

# User schema:
#   users/{user_type}/{user_id}: A user hash, the user id is the unique id from users source (like Tencent).
#   users/{user_type}/{user_id}/group_ids: Set of group ids the user belongs.
class User < Base
  def save
    $redis.hmset key, *attributes.except('type', 'id').to_a.flatten
  end

  def group_ids
    $redis.smembers group_ids_key
  end

  def group_ids_key
    "#{key}/group_ids"
  end

  def key
    "users/#{@attributes['type']}/#{@attributes['id']}"
  end
end
