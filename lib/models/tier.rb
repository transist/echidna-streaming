# coding: utf-8
require_relative 'base'

class Tier < Base
  def add_city(city)
    City.new("name" => city)["tier_id"] = @attributes["id"]
  end

  def remove_city(city)
    City.new("name" => city)["tier_id"] = nil
  end
end
