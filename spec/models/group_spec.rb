# coding: utf-8
require "spec_helper"

describe Group do
  before do
    $redis.flushdb
  end

  context "#save" do
    before do
      Group.new({"id" => "group-1", "name" => "Group 1"}).save
    end

    it "should save group attributes" do
      attributes = $redis.hgetall "groups:group-1"
      expect(attributes).to eq({"name" => "Group 1"})
    end
  end

  context "#trends" do
    subject { Group.new("id" => "group-1") }
    before do
      Source.new("id" => "source-1", "url" => "http://t.qq.com/t/source-1").save
      Source.new("id" => "source-2", "url" => "http://t.qq.com/t/source-2").save
      Source.new("id" => "source-3", "url" => "http://t.qq.com/t/source-3").save
      Keyword.new({"group_id" => "group-1", "timestamp" => "20130222005534", "word" => "中国", "source_id" => "source-1"}).save
      Keyword.new({"group_id" => "group-1", "timestamp" => "20130222005718", "word" => "中国", "source_id" => "source-3"}).save
      Keyword.new({"group_id" => "group-1", "timestamp" => "20130222005534", "word" => "中间", "source_id" => "source-2"}).save
    end

    it "should get trends when timestamp in the period" do
      expect(subject.trends('minute', "20130222005500", "20130222013000")).to eq({
        "201302220055" => [
          { "word" => "中国", "count" => 1, "source" => "http://t.qq.com/t/source-1" },
          { "word" => "中间", "count" => 1, "source" => "http://t.qq.com/t/source-2" }
        ],
        "201302220057" => [
          { "word" => "中国", "count" => 1, "source" => "http://t.qq.com/t/source-3" }
        ]
      })
      expect(subject.trends('hour', "20130222000000", "20130222090000")).to eq({
        "2013022200" => [
          { "word" => "中国", "count" => 2, "source" => "http://t.qq.com/t/source-3" },
          { "word" => "中间", "count" => 1, "source" => "http://t.qq.com/t/source-2" }
        ]
      })
      expect(subject.trends('day', "20130222000000", "20130222000000")).to eq({
        "20130222" => [
          { "word" => "中国", "count" => 2, "source" => "http://t.qq.com/t/source-3" },
          { "word" => "中间", "count" => 1, "source" => "http://t.qq.com/t/source-2" }
        ]
      })
      expect(subject.trends('month', "20130201000000", "20130201000000")).to eq({
        "201302" => [
          { "word" => "中国", "count" => 2, "source" => "http://t.qq.com/t/source-3" },
          { "word" => "中间", "count" => 1, "source" => "http://t.qq.com/t/source-2" }
        ]
      })
      expect(subject.trends('year', "20130101000000", "20130101000000")).to eq({
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
      expect($redis.smembers("groups:group-1:users")).to be_include @user.key
    end

    it "should assign group id to user hash" do
      expect($redis.hget @user.key, "group_id").to eq "group-1"
    end
  end

  context "#key" do
    subject { Group.new({"id" => "group-1", "name" => "Group 1"}) }

    its(:key) { should eq "groups:group-1" }
  end

  context "#users_key" do
    subject { Group.new({"id" => "group-1", "name" => "Group 1"}) }

    its(:users_key) { should eq "groups:group-1:users" }
  end
end
