# coding: utf-8
class Base
  attr_accessor :attributes, :store
  def initialize(attributes, store)
    @attributes = attributes
    @store = store
  end
end
