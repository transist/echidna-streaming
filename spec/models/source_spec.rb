# coding: utf-8
require "spec_helper"

describe Source do
  before do
    flush_redis
  end

  context "#save" do
    before do
      Source.new({"id" => "1234567890", "url" => "http://t.qq.com/t/1234567890"}).save
    end

    it "should save source attributes" do
      attributes = $redis.hgetall "sources/1234567890"
      expect(attributes).to eq({"url" => "http://t.qq.com/t/1234567890"})
    end
  end

  context "#exist?" do
    subject { Source.new({"id" => "1234567890", "url" => "http://t.qq.com/t/1234567890"}) }

    its(:exist?) { should be_false }

    it "should be true after saving" do
      subject.save
      expect(subject).to be_exist
    end
  end

  context "#key" do
    subject { Source.new({"id" => "1234567890", "url" => "http://t.qq.com/t/1234567890"}) }

    its(:key) { should eq "sources/1234567890" }
  end
end
