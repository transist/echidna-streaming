# coding: utf-8
class Keyword < Base
  def save
    $redis.incr minute_key
    $redis.incr hour_key
    $redis.incr day_key
    $redis.incr month_key
    $redis.incr year_key
  end

  def minute_key
    "groups:#{@attributes['group_id']}:minute:#{Time.at(@attributes['timestamp']).utc.change(sec: 0).to_i}:#{@attributes['word']}"
  end

  def hour_key
    "groups:#{@attributes['group_id']}:hour:#{Time.at(@attributes['timestamp']).utc.beginning_of_hour.to_i}:#{@attributes['word']}"
  end

  def day_key
    "groups:#{@attributes['group_id']}:day:#{Time.at(@attributes['timestamp']).utc.beginning_of_day.to_i}:#{@attributes['word']}"
  end

  def month_key
    "groups:#{@attributes['group_id']}:month:#{Time.at(@attributes['timestamp']).utc.beginning_of_month.to_i}:#{@attributes['word']}"
  end

  def year_key
    "groups:#{@attributes['group_id']}:year:#{Time.at(@attributes['timestamp']).utc.beginning_of_year.to_i}:#{@attributes['word']}"
  end
end
