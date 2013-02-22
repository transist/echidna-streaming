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
      Keyword.new({"group_id" => "group-1", "timestamp" => 1361494534, "word" => "中国"}).save
      Keyword.new({"group_id" => "group-1", "timestamp" => 1361494534, "word" => "中间"}).save
      Keyword.new({"group_id" => "group-1", "timestamp" => 1361494638, "word" => "中国"}).save
    end

    it "should get trends when timestamp in the period" do
      expect(subject.trends('minute', 1361494500, 1361496600)).to eq("1361494500" => {"中国"=>1, "中间"=>1}, "1361494620" => {"中国"=>1})
      expect(subject.trends('hour', 1361491200, 1361523600)).to eq("1361491200" => {"中国"=>2, "中间"=>1})
      expect(subject.trends('day', 1361491200, 1361491200)).to eq("1361491200" => {"中国"=>2, "中间"=>1})
      expect(subject.trends('month', 1359676800, 1359676800)).to eq("1359676800" => {"中国"=>2, "中间"=>1})
      expect(subject.trends('year', 1356998400, 1356998400)).to eq("1356998400" => {"中国"=>2, "中间"=>1})
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
