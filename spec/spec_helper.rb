# coding: utf-8
streaming_env = ENV['ECHIDNA_STREAMING_ENV'] || "test"
redis_host = ENV['ECHIDNA_REDIS_HOST'] || "127.0.0.1"
redis_port = ENV['ECHIDNA_REDIS_PORT'] || "6379"
redis_namespace = ENV['ECHIDNA_REDIS_NAMESPACE'] || "e:t"

require "bundler"
Bundler.require(:default, streaming_env.to_sym)

Dir["lib/helpers/*.rb"].each { |file| require_relative "../#{file}" }
Dir["lib/models/*.rb"].each { |file| require_relative "../#{file}" }

$redis = Redis::Namespace.new(redis_namespace, redis: Redis.new(host: redis_host, port: redis_port, driver: "hiredis"))

def flush_redis
  $redis.keys("*").each do |key|
    $redis.del key
  end
end

RSpec.configure do |config|
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
end
