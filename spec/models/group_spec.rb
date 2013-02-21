# coding: utf-8
require "spec_helper"

describe Group do
  before do
    $redis.flushdb
  end

  context "#add_user" do
    before do
      @user = User.new({"id" => "1234567890", "type" => "tecent", "birth_year" => 2000, "gender" => "f", "city" => "shanghai"})
      Group.new({"name" => "group-1"}).add_user @user
    end

    it "should add a user" do
      expect($redis.smembers("groups:group-1:users")).to be_include @user.key
    end

    it "should assign group key to user hash" do
      expect($redis.hget @user.key, "group_key").to eq "groups:group-1"
    end
  end

  context "#key" do
    subject { Group.new({"name" => "group-1"}) }

    its(:key) { should eq "groups:group-1" }
  end

  context "#users_key" do
    subject { Group.new({"name" => "group-1"}) }

    its(:users_key) { should eq "groups:group-1:users" }
  end
end
