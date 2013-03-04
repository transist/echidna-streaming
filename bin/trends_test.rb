# coding: utf-8
require 'bundler'
Bundler.require(:default, ENV['ECHIDNA_ENV'] || "development")
require 'time'

group_id, interval, start_time, end_time = *ARGV

start_timestamp = Time.parse(start_time)
end_timestamp = Time.parse(end_time)
keywords = Group.new("id" => group_id).trends(interval, start_timestamp, end_timestamp)
puts keywords
