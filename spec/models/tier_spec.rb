# coding: utf-8
require "spec_helper"

describe Tier do
  before do
    flush_redis
  end

  context "#save" do
    before do
      Tier.new("id" => "tier-1", "name" => "Tier 1").save
    end

    it "should save group attributes" do
      attributes = $redis.hgetall "tiers/tier-1"
      expect(attributes).to eq({"name" => "Tier 1"})
    end
  end

  context "#add_city" do
    before do
      @tier = Tier.new("id" => "tier-1", "name" => "Tier 1")
      @tier.save
      @tier.add_city "Shanghai"
    end

    it "should get Shanghai" do
      expect($redis.smembers @tier.cities_key).to eq ["Shanghai"]
    end
  end

  context "#key" do
    subject { Tier.new("id" => "tier-1", "name" => "Tier 1") }
    its(:key) { should eq "tiers/tier-1" }
  end

  context "#cities_key" do
    subject { Tier.new("id" => "tier-1", "name" => "Tier 1") }
    its(:cities_key) { should eq "tiers/tier-1/cities" }
  end
end
