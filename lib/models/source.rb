# coding: utf-8
require_relative 'base'

class Source < Base
  def url
    $redis.hget key, 'url'
  end
end
