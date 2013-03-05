# coding: utf-8
require 'bundler'
Bundler.require(:default, ENV['ECHIDNA_ENV'] || "development")

index = 1

genders = ["male", "female", "both"]
birth_years = [[1947, 1953], [1954, 1960], [1961, 1967], [1968, 1974], [1975, 1981], [1982, 1988], [1989, 1995], [1996, 2002], [2003, 2009], [2010, 2013]]

Tier.new("id" => "tier-1", "name" => "Tier 1").save
genders.each do |gender|
  birth_years.each do |start_birth_year, end_birth_year|
    %w(北京 上海 广州 深圳 天津 重庆).each do |city|
      City.new("name" => city)["tier_id"] = "tier-1"
      Group.new("id" => "group-#{index}", "name" => "Group #{index}", "gender" => gender, "start_birth_year" => start_birth_year, "end_birth_year" => end_birth_year, "city" => city).save
      index += 1
    end
    Group.new("id" => "group-#{index}", "name" => "Group #{index}", "gender" => gender, "start_birth_year" => start_birth_year, "end_birth_year" => end_birth_year, "tier_id" => "tier-1").save
    index += 1
  end
end

Tier.new("id" => "tier-2", "name" => "Tier 2").save
genders.each do |gender|
  birth_years.each do |start_birth_year, end_birth_year|
    %w(南京 武汉 沈阳 西安 成都 杭州 济南 青岛 大连 宁波 苏州 无锡 哈尔滨 长春 厦门 佛山 东莞 合肥 郑州 长沙 福州 石家庄 乌鲁木齐 昆明 兰州 南昌 贵阳 南宁 太原 呼和浩特 常州 唐山 准二线 烟台 泉州 包头 徐州 南通 邯郸 温州).each do |city|
      City.new("name" => city)["tier_id"] = "tier-2"
      Group.new("id" => "group-#{index}", "name" => "Group #{index}", "gender" => gender, "start_birth_year" => start_birth_year, "end_birth_year" => end_birth_year, "city" => city).save
      index += 1
    end
    Group.new("id" => "group-#{index}", "name" => "Group #{index}", "gender" => gender, "start_birth_year" => start_birth_year, "end_birth_year" => end_birth_year, "tier_id" => "tier-2").save
    index += 1
  end
end

genders.each do |gender|
  birth_years.each do |start_birth_year, end_birth_year|
    Tier.new("id" => "tier-other", "name" => "Other Tier").save
    Group.new("id" => "group-other", "name" => "Other Group", "gender" => "female", "start_birth_year" => 1989, "end_birth_year" => 1995, "tier_id" => "tier-other").save
  end
end
