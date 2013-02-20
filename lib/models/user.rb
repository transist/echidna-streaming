# encoding: utf-8
class User < Base
  def save
    @store.set "foo", "bar"
    @store.hmset "users:tw:#{@attributes.delete('id')}", *attributes.to_a.flatten
  end
end
