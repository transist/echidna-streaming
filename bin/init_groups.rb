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

Tier.new("id" => "tier-1", "name" => "Tier 1").save
%w(北京 上海 广州 深圳 天津 重庆).each do |city|
  City.new("name" => city)["tier_id"] = "tier-1"
end
Group.new("id" => "group-1", "name" => "Group 1", "gender" => "female", "start_birth_year" => 1989, "end_birth_year" => 1995, "tier_id" => "tier-1").save

Tier.new("id" => "tier-2", "name" => "Tier 2").save
%w(南京 武汉 沈阳 西安 成都 杭州 济南 青岛 大连 宁波 苏州 无锡 哈尔滨 长春 厦门 佛山 东莞 合肥 郑州 长沙 福州 石家庄 乌鲁木齐 昆明 兰州 南昌 贵阳 南宁 太原 呼和浩特 常州 唐山 准二线 烟台 泉州 包头 徐州 南通 邯郸 温州).each do |city|
  City.new("name" => city)["tier_id"] = "tier-2"
end
Group.new("id" => "group-2", "name" => "Group 2", "gender" => "female", "start_birth_year" => 1989, "end_birth_year" => 1995, "tier_id" => "tier-2").save

Tier.new("id" => "tier-other", "name" => "Other Tier").save
Group.new("id" => "group-other", "name" => "Other Group", "gender" => "female", "start_birth_year" => 1989, "end_birth_year" => 1995, "tier_id" => "tier-other").save
