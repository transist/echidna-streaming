require "bundler"
Bundler.require(:default, :test)

Dir["lib/models/*.rb"].each { |file| require_relative "../#{file}" }

$redis = Redis.new driver: :hiredis

RSpec.configure do |config|
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
end
