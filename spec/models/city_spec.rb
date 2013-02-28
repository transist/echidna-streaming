# coding: utf-8
require "spec_helper"

describe City do
  before do
    flush_redis
  end

  context "#save" do
    before do
      City.new("name" => "Shanghai", "tier_id" => "tier-1").save
    end

    it "should save group attributes" do
      attributes = $redis.hgetall "city/shanghai"
      expect(attributes).to eq({"tier_id" => "tier-1"})
    end
  end

  context "#key" do
    subject { City.new("name" => "Shanghai", "tier_id" => "tier-1") }
    its(:key) { should eq "city/shanghai" }
  end
end
