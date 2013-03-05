# coding: utf-8
require "spec_helper"

describe Tier do
  before do
    flush_redis
  end

  context ".all" do
    before do
      tier = Tier.new("id" => "tier-1", "name" => "Tier 1")
      tier.save
      tier.add_city("北京")
      tier.add_city("上海")

      tier = Tier.new("id" => "tier-2", "name" => "Tier 2")
      tier.save
      tier.add_city("杭州")
    end

    it "should get all tiers" do
      expect(Tier.all).to eq [
        {"id" => "tier-1", "name" => "Tier 1", "cities" => ["上海", "北京"]},
        {"id" => "tier-2", "name" => "Tier 2", "cities" => ["杭州"]}
      ]
    end
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
      tier = Tier.new("id" => "tier-1", "name" => "Tier 1")
      tier.save
      tier.add_city("上海")
    end

    it "should add Shanghai to Tier 1" do
      expect(City.new("name" => "上海")["tier_id"]).to eq "tier-1"
    end
  end

  context "#remove_city" do
    before do
      tier = Tier.new("id" => "tier-1", "name" => "Tier 1")
      tier.save
      tier.add_city("上海")
      tier.remove_city("上海")
    end

    it "should no tier for Shanghai" do
      expect(City.new("name" => "上海")["tier_id"]).to be_blank
    end
  end

  context "#cities" do
    before do
      @tier = Tier.new("id" => "tier-1", "name" => "Tier 1")
      @tier.save
      @tier.add_city("上海")
      @tier.add_city("北京")
      tier2 = Tier.new("id" => "tier-2", "name" => "Tier 2")
      tier2.save
      tier2.add_city("杭州")
    end

    it "should list all cities" do
      expect(@tier.cities).to eq ["北京", "上海"]
    end
  end

  context "#key" do
    subject { Tier.new("id" => "tier-1", "name" => "Tier 1") }
    its(:key) { should eq "tiers/tier-1" }
  end
end
