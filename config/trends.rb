redis_config = YAML.load_file("config/redis.yml")[ENV['ECHIDNA_ENV']]
$redis = Redis::Namespace.new(redis_config.delete("namespace"), redis: Redis.new(redis_config.merge(driver: "synchrony")))
