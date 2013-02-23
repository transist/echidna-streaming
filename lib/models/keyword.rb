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
      $redis.zadd minute_keywords_key, minute_timestamp, minute_key
      $redis.zadd hour_keywords_key, hour_timestamp, hour_key
      $redis.zadd day_keywords_key, day_timestamp, day_key
      $redis.zadd month_keywords_key, month_timestamp, month_key
      $redis.zadd year_keywords_key, year_timestamp, year_key
      $redis.incr minute_key
      $redis.incr hour_key
      $redis.incr day_key
      $redis.incr month_key
      $redis.incr year_key
    end
  end

  def minute_key
    "groups:#{@attributes['group_id']}:minute:#{minute_timestamp}:#{@attributes['word']}"
  end

  def hour_key
    "groups:#{@attributes['group_id']}:hour:#{hour_timestamp}:#{@attributes['word']}"
  end

  def day_key
    "groups:#{@attributes['group_id']}:day:#{day_timestamp}:#{@attributes['word']}"
  end

  def month_key
    "groups:#{@attributes['group_id']}:month:#{month_timestamp}:#{@attributes['word']}"
  end

  def year_key
    "groups:#{@attributes['group_id']}:year:#{year_timestamp}:#{@attributes['word']}"
  end

  def minute_source_id_key
    "groups:#{@attributes['group_id']}:minute:#{minute_timestamp}:#{@attributes['word']}:source_id"
  end

  def hour_source_id_key
    "groups:#{@attributes['group_id']}:hour:#{hour_timestamp}:#{@attributes['word']}:source_id"
  end

  def day_source_id_key
    "groups:#{@attributes['group_id']}:day:#{day_timestamp}:#{@attributes['word']}:source_id"
  end

  def month_source_id_key
    "groups:#{@attributes['group_id']}:month:#{month_timestamp}:#{@attributes['word']}:source_id"
  end

  def year_source_id_key
    "groups:#{@attributes['group_id']}:year:#{year_timestamp}:#{@attributes['word']}:source_id"
  end

  def minute_keywords_key
    "groups:#{@attributes['group_id']}:minute:keywords"
  end

  def hour_keywords_key
    "groups:#{@attributes['group_id']}:hour:keywords"
  end

  def day_keywords_key
    "groups:#{@attributes['group_id']}:day:keywords"
  end

  def month_keywords_key
    "groups:#{@attributes['group_id']}:month:keywords"
  end

  def year_keywords_key
    "groups:#{@attributes['group_id']}:year:keywords"
  end

  def minute_timestamp
    @attributes['timestamp'].sub(/\d{2}$/, '00')
  end

  def hour_timestamp
    @attributes['timestamp'].sub(/\d{4}$/, '0000')
  end

  def day_timestamp
    @attributes['timestamp'].sub(/\d{6}$/, '000000')
  end

  def month_timestamp
    @attributes['timestamp'].sub(/\d{8}$/, '01000000')
  end

  def year_timestamp
    @attributes['timestamp'].sub(/\d{10}$/, '0101000000')
  end
end
