# coding: utf-8
require 'bundler'
Bundler.require(:default, ENV['ECHIDNA_ENV'] || "development")

puts "Start creating groups..."

index = 1

genders_data = MultiJson.decode(File.read("echidna-data/data/genders.json"))["genders"]
birth_years_data = MultiJson.decode(File.read("echidna-data/data/birth_years.json"))["birth_years"]
tiers_data = MultiJson.decode(File.read("echidna-data/data/tiers.json"))["tiers"]

tiers_data.each do |tier_data|
  cities_data = tier_data.delete "cities"
  tier = Tier.new(tier_data)
  tier.save
  genders_data.each do |gender_data|
    birth_years_data.each do |birth_year_data|
      start_birth_year_data = birth_year_data["start_birth_year"]
      end_birth_year_data = birth_year_data["end_birth_year"]
      cities_data.each do |city_data|
        tier.add_city(city_data)
        Group.new("id" => "group-#{index}", "name" => "Group #{index}", "gender" => gender_data, "start_birth_year" => start_birth_year_data, "end_birth_year" => end_birth_year_data, "city" => city_data).save
        index += 1
      end
      Group.new("id" => "group-#{index}", "name" => "Group #{index}", "gender" => gender_data, "start_birth_year" => start_birth_year_data, "end_birth_year" => end_birth_year_data, "tier_id" => tier_data["id"]).save
      index += 1
    end
  end
end

Tier.new("id" => "tier-other", "name" => "Other Tier").save
Group.new("id" => "group-other", "name" => "Other Group", "gender" => "", "start_birth_year" => 0, "end_birth_year" => 0, "tier_id" => "tier-other").save

puts "Finish creating groups"
