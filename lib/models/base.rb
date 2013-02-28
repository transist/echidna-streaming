# coding: utf-8
class Base
  attr_accessor :attributes

  def initialize(attributes)
    @attributes = attributes
  end

  def save
    $redis.hmset key, *attributes.except('id').to_a.flatten
  end

  def [](key)
    $redis.hget key
  end

  def []=(key, value)
    $redis.hset key, value
  end

  def key
    [self.class.to_s.tableize, @attributes['id']].join('/')
  end
end
