# coding: utf-8
require "spec_helper"

describe Group do
  before do
    flush_redis
  end

  context ".new_with_key" do
    it "should set group id" do
      expect(Group.new_with_key("groups/group-1", {}).key).to eq "groups/group-1"
    end
  end

  context ".all" do
    before do
      tier = Tier.new("id" => "tier-1", "name" => "Tier 1")
      tier.save
      tier.add_city("上海")
      Group.new("id" => "group-1", "name" => "Group 1", "gender" => "female", "start_birth_year" => 1993, "end_birth_year" => 1995, "city" => "上海").save
      Group.new("id" => "group-2", "name" => "Group 2", "gender" => "female", "start_birth_year" => 1993, "end_birth_year" => 1995, "tier_id" => "tier-1").save
      Group.new("id" => "group-3", "name" => "Group 3", "gender" => "both", "start_birth_year" => 1993, "end_birth_year" => 1995, "city" => "上海").save
      tier = Tier.new("id" => "tier-2", "name" => "Tier 2")
      tier.save
      tier.add_city("北京")
      Group.new("id" => "group-4", "name" => "Group 4", "gender" => "female", "start_birth_year" => 1993, "end_birth_year" => 1995, "city" => "北京").save
      Group.new("id" => "group-5", "name" => "Group 5", "gender" => "female", "start_birth_year" => 1993, "end_birth_year" => 1995, "tier_id" => "tier-2").save
      Group.new("id" => "group-6", "name" => "Group 6", "gender" => "both", "start_birth_year" => 1993, "end_birth_year" => 1995, "city" => "北京").save
    end

    it "should get all groups" do
      expect(Group.all).to include({"id" => "group-1", "name" => "Group 1", "gender" => "female", "start_birth_year" => "1993", "end_birth_year" => "1995", "city" => "上海"})
      expect(Group.all).to include({"id" => "group-2", "name" => "Group 2", "gender" => "female", "start_birth_year" => "1993", "end_birth_year" => "1995", "tier_id" => "tier-1"})
      expect(Group.all).to include({"id" => "group-3", "name" => "Group 3", "gender" => "both", "start_birth_year" => "1993", "end_birth_year" => "1995", "city" => "上海"})
      expect(Group.all).to include({"id" => "group-4", "name" => "Group 4", "gender" => "female", "start_birth_year" => "1993", "end_birth_year" => "1995", "city" => "北京"})
      expect(Group.all).to include({"id" => "group-5", "name" => "Group 5", "gender" => "female", "start_birth_year" => "1993", "end_birth_year" => "1995", "tier_id" => "tier-2"})
      expect(Group.all).to include({"id" => "group-6", "name" => "Group 6", "gender" => "both", "start_birth_year" => "1993", "end_birth_year" => "1995", "city" => "北京"})
    end
  end

  context ".find_group_ids" do
    before do
      tier = Tier.new("id" => "tier-1", "name" => "Tier 1")
      tier.save
      tier.add_city("上海")
      Group.new("id" => "group-1", "name" => "Group 1", "gender" => "female", "start_birth_year" => 1993, "end_birth_year" => 1995, "city" => "上海").save
      Group.new("id" => "group-2", "name" => "Group 2", "gender" => "female", "start_birth_year" => 1993, "end_birth_year" => 1995, "tier_id" => "tier-1").save
      Group.new("id" => "group-3", "name" => "Group 3", "gender" => "both", "start_birth_year" => 1993, "end_birth_year" => 1995, "city" => "上海").save
      tier = Tier.new("id" => "tier-2", "name" => "Tier 2")
      tier.save
      tier.add_city("北京")
      Group.new("id" => "group-4", "name" => "Group 4", "gender" => "female", "start_birth_year" => 1993, "end_birth_year" => 1995, "city" => "北京").save
      Group.new("id" => "group-5", "name" => "Group 5", "gender" => "female", "start_birth_year" => 1993, "end_birth_year" => 1995, "tier_id" => "tier-2").save
      Group.new("id" => "group-6", "name" => "Group 6", "gender" => "both", "start_birth_year" => 1993, "end_birth_year" => 1995, "city" => "北京").save

      Tier.new("id" => "tier-other", "name" => "Other Tier").save
      Group.new("id" => "group-other", "name" => "Other Group", "gender" => "", "start_birth_year" => 0, "end_birth_year" => 0, "tier" => "tier-other").save
    end

    it "should get group-1" do
      expect(Group.find_group_ids("female", "1994", "上海")).to eq ["group-2", "group-3", "group-1"]
    end

    it "should get group-other" do
      expect(Group.find_group_ids("", "1984", "上海")).to eq ["group-other"]
      expect(Group.find_group_ids("female", "0", "上海")).to eq ["group-other"]
      expect(Group.find_group_ids("female", "1984", "西藏")).to eq ["group-other"]
    end
  end

  context ".find_tier_group_ids" do
    before do
      Tier.new("id" => "tier-1", "name" => "Tier 1").save
      Tier.new("id" => "tier-2", "name" => "Tier 2").save

      Group.new("id" => "group-1", "name" => "Group 1", "gender" => "male", "start_birth_year" => 1989, "end_birth_year" => 1995, "tier_id" => "tier-1").save
      Group.new("id" => "group-2", "name" => "Group 2", "gender" => "female", "start_birth_year" => 1982, "end_birth_year" => 1988, "tier_id" => "tier-2").save
      Group.new("id" => "group-other", "name" => "Group Other", "gender" => "Both", "start_birth_year" => 1982, "end_birth_year" => 1988, "tier_id" => "tier-other").save
    end

    it "should get group-1" do
      expect(Group.find_tier_group_id("Men", "18-", "tier-1")).to eq "group-1"
    end

    #it "should get group-other" do
      #expect(Group.find_group_ids("", "1984", "上海")).to eq ["group-other"]
      #expect(Group.find_group_ids("female", "0", "上海")).to eq ["group-other"]
      #expect(Group.find_group_ids("female", "1984", "西藏")).to eq ["group-other"]
    #end
  end

  context "#save" do
    before do
      Group.new({"id" => "group-1", "name" => "Group 1", "gender" => "female", "start_age" => 18, "end_age" => 24, "tier" => "Tier 1"}).save
    end

    it "should save group attributes" do
      attributes = $redis.hgetall "groups/group-1"
      expect(attributes).to eq({"name" => "Group 1", "gender" => "female", "start_age" => "18", "end_age" => "24", "tier" => "Tier 1"})
    end

    it "should add to groups key" do
      expect($redis.smembers("groups")).to include("groups/group-1")
    end
  end

  context "#trends" do
    subject { Group.new("id" => "group-1") }
    before do
      Source.new("id" => "source-1", "url" => "http://t.qq.com/t/source-1").save
      Source.new("id" => "source-2", "url" => "http://t.qq.com/t/source-2").save
      Source.new("id" => "source-3", "url" => "http://t.qq.com/t/source-3").save
      Keyword.new({"group_id" => "group-1", "timestamp" => 1361494534, "word" => "中国", "source_id" => "source-1"}).save
      Keyword.new({"group_id" => "group-1", "timestamp" => 1361494638, "word" => "中国", "source_id" => "source-3"}).save
      Keyword.new({"group_id" => "group-1", "timestamp" => 1361494534, "word" => "日本", "source_id" => "source-2"}).save
    end

    it "should get trends when timestamp in the period" do
      expect(subject.trends('second', 1361494534, 1361494535)).to eq([{
        "type" => "second",
        "time" => "2013-02-22T00:55:34",
        "words" => [
          { "word" => "日本", "count" => 1, "source" => "http://t.qq.com/t/source-2" },
          { "word" => "中国", "count" => 1, "source" => "http://t.qq.com/t/source-1" }
        ]
      }, {
        "type" => "second",
        "time" => "2013-02-22T00:55:35",
        "words" => []
      }])
      expect(subject.trends('minute', 1361494500, 1361494620)).to eq([{
        "type" => "minute",
        "time" => "2013-02-22T00:55",
        "words" => [
          { "word" => "日本", "count" => 1, "source" => "http://t.qq.com/t/source-2" },
          { "word" => "中国", "count" => 1, "source" => "http://t.qq.com/t/source-1" }
        ]
      }, {
        "type" => "minute",
        "time" => "2013-02-22T00:56",
        "words" => []
      }, {
        "type" => "minute",
        "time" => "2013-02-22T00:57",
        "words" => [
          { "word" => "中国", "count" => 1, "source" => "http://t.qq.com/t/source-3" }
        ]
      }])
      expect(subject.trends('hour', 1361491200, 1361494800)).to eq([{
        "type" => "hour",
        "time" => "2013-02-22T00",
        "words" => [
          { "word" => "中国", "count" => 2, "source" => "http://t.qq.com/t/source-3" },
          { "word" => "日本", "count" => 1, "source" => "http://t.qq.com/t/source-2" }
        ]
      }, {
        "type" => "hour",
        "time" => "2013-02-22T01",
        "words" => []
      }])
      expect(subject.trends('day', 1361491200, 1361491200)).to eq([{
        "type" => "day",
        "time" => "2013-02-22",
        "words" => [
          { "word" => "中国", "count" => 2, "source" => "http://t.qq.com/t/source-3" },
          { "word" => "日本", "count" => 1, "source" => "http://t.qq.com/t/source-2" }
        ]
      }])
      expect(subject.trends('month', 1359676800, 1359676800)).to eq([{
        "type" => "month",
        "time" => "2013-02",
        "words" => [
          { "word" => "中国", "count" => 2, "source" => "http://t.qq.com/t/source-3" },
          { "word" => "日本", "count" => 1, "source" => "http://t.qq.com/t/source-2" }
        ]
      }])
      expect(subject.trends('year', 1356998400, 1356998400)).to eq([{
        "type" => "year",
        "time" => "2013",
        "words" => [
          { "word" => "中国", "count" => 2, "source" => "http://t.qq.com/t/source-3" },
          { "word" => "日本", "count" => 1, "source" => "http://t.qq.com/t/source-2" }
        ]
      }])
    end
  end

  context "#add_user" do
    before do
      @user1 = User.new({"id" => "1234567890", "type" => "tecent", "birth_year" => 2000, "gender" => "f", "city" => "shanghai"})
      @user2 = User.new({"id" => "2234567890", "type" => "tecent", "birth_year" => 2000, "gender" => "m", "city" => "shanghai"})
      Group.new({"id" => "group-1", "name" => "Group 1"}).add_user @user1
      Group.new({"id" => "group-1", "name" => "Group 1"}).add_user @user2
    end

    it "should add a user" do
      expect($redis.smembers("groups/group-1/users")).to be_include @user1.key
      expect($redis.smembers("groups/group-1/users")).to be_include @user2.key
    end

    it "should add group id to the user's group ids set" do
      expect(@user1.group_ids).to include('group-1')
      expect(@user2.group_ids).to include('group-1')
    end
  end

  context "#key" do
    subject { Group.new({"id" => "group-1", "name" => "Group 1"}) }

    its(:key) { should eq "groups/group-1" }
  end

  context "#users_key" do
    subject { Group.new({"id" => "group-1", "name" => "Group 1"}) }

    its(:users_key) { should eq "groups/group-1/users" }
  end

  context ".key" do
    subject { Group }
    its(:key) { should eq "groups" }
  end
end
