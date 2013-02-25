# coding: utf-8
streaming_env = ENV['ECHIDNA_STREAMING_ENV'] || "development"
redis_host = ENV['ECHIDNA_REDIS_HOST'] || "127.0.0.1"
redis_port = ENV['ECHIDNA_REDIS_PORT'] || "6379"
redis_namespace = ENV['ECHIDNA_REDIS_NAMESPACE'] || "e:d"

require 'bundler'
Bundler.require(:default, streaming_env)

Dir["lib/helpers/*.rb"].each { |file| require_relative "../#{file}" }
Dir["lib/models/*.rb"].each { |file| require_relative "../#{file}" }

$redis = Redis::Namespace.new(redis_namespace, redis: Redis.new(host: redis_host, port: redis_port, driver: "hiredis"))
group_id, interval, start_timestamp, end_timestamp = *ARGV

keywords = Group.new("id" => group_id).trends(interval, start_timestamp, end_timestamp)
puts keywords
