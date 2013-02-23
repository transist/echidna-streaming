# coding: utf-8
require "spec_helper"

describe Keyword do
  before do
    $redis.flushdb
  end

  context "#save" do
    before do
      @keyword = Keyword.new({"group_id" => "group-1", "timestamp" => "20130222005534", "word" => "中国", "source_id" => "source-1"})
      @keyword.save
    end

    it "should add keywords to group sorted set" do
      expect($redis.zrange @keyword.minute_keywords_key, 0, -1).to be_include @keyword.minute_key
      expect($redis.zrange @keyword.hour_keywords_key, 0, -1).to be_include @keyword.hour_key
      expect($redis.zrange @keyword.day_keywords_key, 0, -1).to be_include @keyword.day_key
      expect($redis.zrange @keyword.month_keywords_key, 0, -1).to be_include @keyword.month_key
      expect($redis.zrange @keyword.year_keywords_key, 0, -1).to be_include @keyword.year_key
    end

    it "should increment count for all keys" do
      expect($redis.get @keyword.minute_key).to eq "1"
      expect($redis.get @keyword.hour_key).to eq "1"
      expect($redis.get @keyword.day_key).to eq "1"
      expect($redis.get @keyword.month_key).to eq "1"
      expect($redis.get @keyword.year_key).to eq "1"
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
    subject { Keyword.new({"group_id" => "group-1", "timestamp" => "20130222005534", "word" => "中国"}) }

    its(:minute_key) { should eq "groups:group-1:minute:20130222005500:中国" }
    its(:hour_key) { should eq "groups:group-1:hour:20130222000000:中国" }
    its(:day_key) { should eq "groups:group-1:day:20130222000000:中国" }
    its(:month_key) { should eq "groups:group-1:month:20130201000000:中国" }
    its(:year_key) { should eq "groups:group-1:year:20130101000000:中国" }
    its(:minute_source_id_key) { should eq "groups:group-1:minute:20130222005500:中国:source_id" }
    its(:hour_source_id_key) { should eq "groups:group-1:hour:20130222000000:中国:source_id" }
    its(:day_source_id_key) { should eq "groups:group-1:day:20130222000000:中国:source_id" }
    its(:month_source_id_key) { should eq "groups:group-1:month:20130201000000:中国:source_id" }
    its(:year_source_id_key) { should eq "groups:group-1:year:20130101000000:中国:source_id" }
    its(:minute_keywords_key) { should eq "groups:group-1:minute:keywords" }
    its(:hour_keywords_key) { should eq "groups:group-1:hour:keywords" }
    its(:day_keywords_key) { should eq "groups:group-1:day:keywords" }
    its(:month_keywords_key) { should eq "groups:group-1:month:keywords" }
    its(:year_keywords_key) { should eq "groups:group-1:year:keywords" }
  end
end
