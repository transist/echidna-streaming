# coding: utf-8
require 'bundler'
Bundler.require(:default, ENV['ECHIDNA_ENV'] || "development")

group_id, interval, start_timestamp, end_timestamp = *ARGV

keywords = Group.new("id" => group_id).trends(interval, start_timestamp, end_timestamp)
puts keywords
