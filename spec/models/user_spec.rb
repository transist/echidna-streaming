# coding: utf-8
require "spec_helper"

describe User do
  before do
    $redis.flushdb
  end

  context "#save" do
    before do
      @user = User.new({"id" => "1234567890", "type" => "tecent", "birth_year" => 2000, "gender" => "f", "city" => "shanghai"})
      @user.save
    end

    it "should save user attributes" do
      attributes = $redis.hgetall "users:tecent:1234567890"
      expect(attributes).to eq({"birth_year" => "2000", "gender" => "f", "city" => "shanghai"})
    end
  end

  context "#key" do
    subject { User.new({"id" => "1234567890", "type" => "tecent", "birth_year" => 2000, "gender" => "f", "city" => "shanghai"}) }

    its(:key) { should eq "users:tecent:1234567890" }
  end

  context "#group_key" do
    before do
      @user = User.new({"id" => "1234567890", "type" => "tecent", "birth_year" => 2000, "gender" => "f", "city" => "shanghai"})
      @group = Group.new({"name" => "group-1"})
      @group.add_user(@user)
    end

    it "should know his group" do
      expect(@user.group_key).to eq @group.key
    end
  end
end
