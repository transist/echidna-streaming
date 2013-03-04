# coding: utf-8
require_relative 'base'

class Keyword < Base
  def save
    $redis.multi do
      $redis.set minute_source_id_key, @attributes['source_id']
      $redis.set hour_source_id_key, @attributes['source_id']
      $redis.set day_source_id_key, @attributes['source_id']
      $redis.set month_source_id_key, @attributes['source_id']
      $redis.set year_source_id_key, @attributes['source_id']

      $redis.zincrby minute_interval_key, 1, @attributes['word']
      $redis.zincrby hour_interval_key, 1, @attributes['word']
      $redis.zincrby day_interval_key, 1, @attributes['word']
      $redis.zincrby month_interval_key, 1, @attributes['word']
      $redis.zincrby year_interval_key, 1, @attributes['word']
    end
  end

  def minute_source_id_key
    "groups/#{@attributes['group_id']}/minute/#{minute_timestamp}/#{@attributes['word']}/source_id"
  end

  def hour_source_id_key
    "groups/#{@attributes['group_id']}/hour/#{hour_timestamp}/#{@attributes['word']}/source_id"
  end

  def day_source_id_key
    "groups/#{@attributes['group_id']}/day/#{day_timestamp}/#{@attributes['word']}/source_id"
  end

  def month_source_id_key
    "groups/#{@attributes['group_id']}/month/#{month_timestamp}/#{@attributes['word']}/source_id"
  end

  def year_source_id_key
    "groups/#{@attributes['group_id']}/year/#{year_timestamp}/#{@attributes['word']}/source_id"
  end

  def minute_keywords_key
    "groups/#{@attributes['group_id']}/minute/keywords"
  end

  def hour_keywords_key
    "groups/#{@attributes['group_id']}/hour/keywords"
  end

  def day_keywords_key
    "groups/#{@attributes['group_id']}/day/keywords"
  end

  def month_keywords_key
    "groups/#{@attributes['group_id']}/month/keywords"
  end

  def year_keywords_key
    "groups/#{@attributes['group_id']}/year/keywords"
  end

  def minute_interval_key
    "groups/#{@attributes['group_id']}/minute/#{minute_timestamp}/keywords"
  end

  def hour_interval_key
    "groups/#{@attributes['group_id']}/hour/#{hour_timestamp}/keywords"
  end

  def day_interval_key
    "groups/#{@attributes['group_id']}/day/#{day_timestamp}/keywords"
  end

  def month_interval_key
    "groups/#{@attributes['group_id']}/month/#{month_timestamp}/keywords"
  end

  def year_interval_key
    "groups/#{@attributes['group_id']}/year/#{year_timestamp}/keywords"
  end

  def minute_timestamp
    Timestamp.new(@attributes['timestamp']).to_minute
  end

  def hour_timestamp
    Timestamp.new(@attributes['timestamp']).to_hour
  end

  def day_timestamp
    Timestamp.new(@attributes['timestamp']).to_day
  end

  def month_timestamp
    Timestamp.new(@attributes['timestamp']).to_month
  end

  def year_timestamp
    Timestamp.new(@attributes['timestamp']).to_year
  end
end
