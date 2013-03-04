# coding: utf-8
require "spec_helper"

describe Keyword do
  before do
    flush_redis
  end

  context "#save" do
    before do
      @keyword = Keyword.new({"group_id" => "group-1", "timestamp" => 1361465734, "word" => "中国", "source_id" => "source-1"})
      @keyword.save
    end

    it "should increment count for minute interval key" do
      expect($redis.zrange @keyword.minute_interval_key, 0, -1, with_scores: true).to be_include ["中国", 1.0]
      expect($redis.zrange @keyword.hour_interval_key, 0, -1, with_scores: true).to be_include ["中国", 1.0]
      expect($redis.zrange @keyword.day_interval_key, 0, -1, with_scores: true).to be_include ["中国", 1.0]
      expect($redis.zrange @keyword.month_interval_key, 0, -1, with_scores: true).to be_include ["中国", 1.0]
      expect($redis.zrange @keyword.year_interval_key, 0, -1, with_scores: true).to be_include ["中国", 1.0]
    end

    it "should set source_id" do
      expect($redis.get @keyword.minute_source_id_key).to eq "source-1"
      expect($redis.get @keyword.hour_source_id_key).to eq "source-1"
      expect($redis.get @keyword.day_source_id_key).to eq "source-1"
      expect($redis.get @keyword.month_source_id_key).to eq "source-1"
      expect($redis.get @keyword.year_source_id_key).to eq "source-1"
    end
  end

  context "keys" do
    subject { Keyword.new({"group_id" => "group-1", "timestamp" => 1361465734, "word" => "中国"}) }

    its(:minute_source_id_key) { should eq "groups/group-1/minute/1361465700/中国/source_id" }
    its(:hour_source_id_key) { should eq "groups/group-1/hour/1361462400/中国/source_id" }
    its(:day_source_id_key) { should eq "groups/group-1/day/1361404800/中国/source_id" }
    its(:month_source_id_key) { should eq "groups/group-1/month/1359676800/中国/source_id" }
    its(:year_source_id_key) { should eq "groups/group-1/year/1356998400/中国/source_id" }
    its(:minute_keywords_key) { should eq "groups/group-1/minute/keywords" }
    its(:hour_keywords_key) { should eq "groups/group-1/hour/keywords" }
    its(:day_keywords_key) { should eq "groups/group-1/day/keywords" }
    its(:month_keywords_key) { should eq "groups/group-1/month/keywords" }
    its(:year_keywords_key) { should eq "groups/group-1/year/keywords" }
  end
end
