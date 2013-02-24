require "bundler"
Bundler.require(:default, :test)

Dir["lib/helpers/*.rb"].each { |file| require_relative "../#{file}" }
Dir["lib/models/*.rb"].each { |file| require_relative "../#{file}" }

redis_config = YAML.load_file("config/redis.yml")["test"]
$redis = Redis.new redis_config.merge(driver: "hiredis")

RSpec.configure do |config|
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
end
