$redis = Redis::Namespace.new($redis_namespace, redis: Redis.new(host: $redis_host, port: $redis_prot, driver: :hiredis))
$logger.notice("connect to redis: #{$redis_host}:#{$redis_port}/#{$redis_namespace}")
