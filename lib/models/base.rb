# coding: utf-8
class Base
  attr_accessor :attributes

  def self.new_with_key(key, attributes)
    id = key.split('/').last
    self.new(attributes.merge("id" => id))
  end

  def initialize(attributes)
    @attributes = attributes
  end

  def save
    $redis.hmset key, *attributes.except('id').to_a.flatten
  end

  def [](attribute_key)
    $redis.hget key, attribute_key
  end

  def []=(attribute_key, value)
    $redis.hset key, attribute_key, value
  end

  def key
    [self.class.to_s.tableize, @attributes['id']].join('/')
  end
end
