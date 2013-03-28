# coding: utf-8
require_relative 'base'
require 'set'

# Group schema:
#   groups: Set of all group keys.
#   groups/group-(\d+): A group hash, the "basename" part of the key is group id.
#   groups/group-(\d+)/users: Set of all user keys in the group.
class Group < Base
  GENDERS = {"Men" => "male", "Women" => "female", "Both" => "both"}
  AGE_RANGES = {'18-' => [1989, 1995], '24-' => [1978, 1989], '35-' => [1973, 1978], '40+' => [1900, 1973], 'All' => [1900, 1989]}

  class <<self
    def all
      $redis.smembers(self.key).map do |group_key|
        $redis.hgetall(group_key).merge("id" => group_key.split('/').last)
      end
    end

    def all_ids
      $redis.smembers(self.key).map do |group_key|
        group_key.split('/').last
      end
    end

    def find_tier_group_id(gender, age_range, tier)
      gender = GENDERS[gender]
      start_birth_year, end_birth_year = AGE_RANGES[age_range]
      $redis.smembers(self.key).each do |group_key|
        group = Group.new_with_key(group_key, $redis.hgetall(group_key))
        # TODO: factor out the birth year matching since we use it in a couple places
        if (group['gender'] == gender || group['gender'] == 'both') &&
           start_birth_year.to_i >= group['start_birth_year'].to_i && end_birth_year.to_i <= group['end_birth_year'].to_i && tier == group['tier_id']
          return group_key.split('/').last
        end
      end
      nil
    end

    def find_group_ids(gender, birth_year, city)
      group_ids = [find_tier_group(gender, birth_year, city), find_city_group(gender, birth_year, city)].compact.flatten
      group_ids.empty? ? ['group-other'] : group_ids
    end

    # expensive operation: fetches and iterates through all group keys
    def find_tier_group(gender, birth_year, city)
      tier_id = City.new("name" => city)["tier_id"] || "tier-other"
      groups = []
      $redis.smembers(self.key).each do |group_key|
        group = Group.new_with_key(group_key, $redis.hgetall(group_key))
        if (group['gender'] == gender || group['gender'] == 'both') &&
           birth_year.to_i >= group['start_birth_year'].to_i && birth_year.to_i <= group['end_birth_year'].to_i &&
           tier_id == group['tier_id']
          groups << group_key.split('/').last
        end
      end
      groups
    end

    def find_city_group(gender, birth_year, city)
      groups = []
      $redis.smembers(self.key).each do |group_key|
        group = Group.new_with_key(group_key, $redis.hgetall(group_key))
        if (group['gender'] == gender || group['gender'] == 'both') &&
           birth_year.to_i >= group['start_birth_year'].to_i && birth_year.to_i <= group['end_birth_year'].to_i &&
           city == group['city']
          groups << group_key.split('/').last
        end
      end
      groups
    end
  end

  def save
    super
    $redis.sadd self.class.key, self.key
  end

  def trends(interval, start_timestamp, end_timestamp, limit=100)
    start_timestamp = Timestamp.new(start_timestamp).send("to_#{interval}")
    end_timestamp = Timestamp.new(end_timestamp).send("to_#{interval}")
    interval_timestamp = 1.send(interval)

    trends = []
    while (start_timestamp <= end_timestamp)
      timestamp = Timestamp.new(Time.at(start_timestamp.to_i)).send("to_formatted_#{interval}")
      interval_trends = {"type" => interval, "time" => timestamp}
      result = $redis.zrevrange "groups/#{@attributes['id']}/#{interval}/#{start_timestamp}/keywords", 0, limit - 1, with_scores: true
      words = []
      result.each do |word, count|
        source_id = $redis.get("groups/#{@attributes['id']}/#{interval}/#{start_timestamp}/#{word}/source_id")
        source_url = Source.new("id" => source_id).url
        words << {"word" => word, "count" => count.to_i, "source" => source_url}
      end
      interval_trends["words"] = words
      trends << interval_trends
      # TODO: rename interval_increment
      start_timestamp += interval_timestamp
    end
    trends
  end

  def add_user(user)
    $redis.multi do
      $redis.sadd users_key, user.key
      $redis.sadd user.group_ids_key, @attributes['id']
    end
  end

  def users_key
    "groups/#{@attributes['id']}/users"
  end

  def self.key
    "groups"
  end
end
