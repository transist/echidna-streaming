# coding: utf-8
class Keyword < Base
  def save
    $redis.multi do
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
    Time.at(@attributes['timestamp']).utc.change(sec: 0).to_i
  end

  def hour_timestamp
    Time.at(@attributes['timestamp']).utc.beginning_of_hour.to_i
  end

  def day_timestamp
    Time.at(@attributes['timestamp']).utc.beginning_of_day.to_i
  end

  def month_timestamp
    Time.at(@attributes['timestamp']).utc.beginning_of_month.to_i
  end

  def year_timestamp
    Time.at(@attributes['timestamp']).utc.beginning_of_year.to_i
  end
end
