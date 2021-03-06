# coding: utf-8
require "spec_helper"

describe User do
  before do
    flush_redis
  end

  context "#save" do
    before do
      User.new({"id" => "1234567890", "type" => "tencent", "birth_year" => 2000, "gender" => "f", "city" => "shanghai"}).save
    end

    it "should save user attributes" do
      attributes = $redis.hgetall "users/tencent/1234567890"
      expect(attributes).to eq({"birth_year" => "2000", "gender" => "f", "city" => "shanghai"})
    end
  end

  context "#key" do
    subject { User.new({"id" => "1234567890", "type" => "tencent", "birth_year" => 2000, "gender" => "f", "city" => "shanghai"}) }

    its(:key) { should eq "users/tencent/1234567890" }
  end
end
