# coding: utf-8
ENV['ECHIDNA_ENV'] = 'test'

require "bundler"
Bundler.require(:default, :test)

def flush_redis
  $redis.keys("*").each do |key|
    $redis.del key
  end
end

RSpec.configure do |config|
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
end
