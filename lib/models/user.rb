# coding: utf-8
class User < Base
  def save
    @store.hmset "users:#{@attributes.delete('type')}:#{@attributes.delete('id')}", *attributes.to_a.flatten
  end
end
