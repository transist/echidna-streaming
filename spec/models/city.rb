# coding: utf-8
require "spec_helper"

describe City do
  before do
    flush_redis
  end

  context "#save" do
    before do
      City.new("id" => "city-1", "name" => "City 1").save
    end

    it "should save group attributes" do
      attributes = $redis.hgetall "citys/city-1"
      expect(attributes).to eq({"name" => "City 1"})
    end
  end

  context "#key" do
    subject { City.new("id" => "city-1", "name" => "City 1") }
    its(:key) { should eq "citys/city-1" }
  end
end
