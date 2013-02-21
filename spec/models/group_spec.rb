# coding: utf-8
require "spec_helper"

describe Group do
  before do
    $redis.flushdb
  end

  context "#add_user" do
    before do
      @group = Group.new({"name" => "group-1"})
      @user = User.new({"id" => "1234567890", "type" => "tecent", "birth_year" => 2000, "gender" => "f", "city" => "shanghai"})
      @group.add_user @user
    end

    it "should add a user" do
      expect($redis.smembers("groups:group-1")).to be_include @user.key
    end
  end

  context "#key" do
    subject { Group.new({"name" => "group-1"}) }

    its(:key) { should eq "groups:group-1" }
  end
end
