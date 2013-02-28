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

  context ".find_gropu_id" do
    before do
      tier = Tier.new("id" => "tier-1", "name" => "Tier 1")
      tier.save
      tier.add_city("上海")
      Group.new("id" => "group-1", "name" => "Group 1", "gender" => "female", "start_birth_year" => 1993, "end_birth_year" => 1995, "tier_id" => "tier-1").save
      tier = Tier.new("id" => "tier-2", "name" => "Tier 2")
      tier.save
      tier.add_city("北京")
      Group.new("id" => "group-2", "name" => "Group 2", "gender" => "female", "start_birth_year" => 1993, "end_birth_year" => 1995, "tier_id" => "tier-2").save
    end

    it "should get group-1" do
      expect(Group.find_group_id("female", "1994", "上海")).to eq "group-1"
    end
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
      Keyword.new({"group_id" => "group-1", "timestamp" => "2013-02-22T00:55:34Z", "word" => "中国", "source_id" => "source-1"}).save
      Keyword.new({"group_id" => "group-1", "timestamp" => "2013-02-22T00:57:18Z", "word" => "中国", "source_id" => "source-3"}).save
      Keyword.new({"group_id" => "group-1", "timestamp" => "2013-02-22T00:55:34Z", "word" => "中间", "source_id" => "source-2"}).save
    end

    it "should get trends when timestamp in the period" do
      expect(subject.trends('minute', "2013-02-22T00:55:00Z", "2013-02-22T01:30:00Z")).to eq({
        "2013-02-22T00:55" => [
          { "word" => "中国", "count" => 1, "source" => "http://t.qq.com/t/source-1" },
          { "word" => "中间", "count" => 1, "source" => "http://t.qq.com/t/source-2" }
        ],
        "2013-02-22T00:57" => [
          { "word" => "中国", "count" => 1, "source" => "http://t.qq.com/t/source-3" }
        ]
      })
      expect(subject.trends('hour', "2013-02-22T00:00:00Z", "2013-02-22T09:00:00:Z")).to eq({
        "2013-02-22T00" => [
          { "word" => "中国", "count" => 2, "source" => "http://t.qq.com/t/source-3" },
          { "word" => "中间", "count" => 1, "source" => "http://t.qq.com/t/source-2" }
        ]
      })
      expect(subject.trends('day', "2013-02-22T00:00:00Z", "2013-02-22T00:00:00Z")).to eq({
        "2013-02-22" => [
          { "word" => "中国", "count" => 2, "source" => "http://t.qq.com/t/source-3" },
          { "word" => "中间", "count" => 1, "source" => "http://t.qq.com/t/source-2" }
        ]
      })
      expect(subject.trends('month', "2013-02-01T00:00:00Z", "2013-02-01T00:00:00Z")).to eq({
        "2013-02" => [
          { "word" => "中国", "count" => 2, "source" => "http://t.qq.com/t/source-3" },
          { "word" => "中间", "count" => 1, "source" => "http://t.qq.com/t/source-2" }
        ]
      })
      expect(subject.trends('year', "2013-01-01T00:00:00Z", "2013-01-01T00:00:00Z")).to eq({
        "2013" => [
          { "word" => "中国", "count" => 2, "source" => "http://t.qq.com/t/source-3" },
          { "word" => "中间", "count" => 1, "source" => "http://t.qq.com/t/source-2" }
        ]
      })
    end
  end

  context "#add_user" do
    before do
      @user = User.new({"id" => "1234567890", "type" => "tecent", "birth_year" => 2000, "gender" => "f", "city" => "shanghai"})
      Group.new({"id" => "group-1", "name" => "Group 1"}).add_user @user
    end

    it "should add a user" do
      expect($redis.smembers("groups/group-1/users")).to be_include @user.key
    end

    it "should assign group id to user hash" do
      expect(@user["group_id"]).to eq "group-1"
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
