# coding: utf-8
require 'bundler'
ENV['ECHIDNA_ENV'] ||= "development"
Bundler.require(:default, ENV['ECHIDNA_ENV'])

Dir["lib/helpers/*.rb"].each { |file| require_relative "../#{file}" }
Dir["lib/models/*.rb"].each { |file| require_relative "../#{file}" }

redis_config = YAML.load_file("config/redis.yml")[ENV['ECHIDNA_ENV']]
$redis = Redis.new redis_config.merge(driver: "hiredis")
group_id, interval, start_timestamp, end_timestamp = *ARGV

keywords = Group.new("id" => group_id).trends(interval, start_timestamp, end_timestamp)
puts keywords
