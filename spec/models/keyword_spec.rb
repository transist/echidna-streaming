# coding: utf-8
require "spec_helper"

describe Keyword do
  before do
    $redis.flushdb
  end

  context "#save" do
    before do
      @keyword = Keyword.new({"group_id" => "group-1", "timestamp" => 1361494534, "word" => "中国"})
      @keyword.save
    end

    it "should increment count for all keys" do
      expect($redis.get @keyword.minute_key).to eq "1"
      expect($redis.get @keyword.hour_key).to eq "1"
      expect($redis.get @keyword.day_key).to eq "1"
      expect($redis.get @keyword.month_key).to eq "1"
      expect($redis.get @keyword.year_key).to eq "1"
    end
  end

  context "keys" do
    subject { Keyword.new({"group_id" => "group-1", "timestamp" => 1361494534, "word" => "中国"}) }

    its(:minute_key) { should eq "groups:group-1:minute:1361494500:中国" }
    its(:hour_key) { should eq "groups:group-1:hour:1361491200:中国" }
    its(:day_key) { should eq "groups:group-1:day:1361491200:中国" }
    its(:month_key) { should eq "groups:group-1:month:1359676800:中国" }
    its(:year_key) { should eq "groups:group-1:year:1356998400:中国" }
  end
end
