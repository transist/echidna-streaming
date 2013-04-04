# coding: utf-8
require_relative 'base'

# For now, we only record a single sample source_id per time scale
# see https://github.com/transist/echidna-streaming/issues/36
class Keyword < Base
  def self.calculate_z_scores_for_all_groups(timestamp, interval, limit = 100)
    time = Time.at(timestamp)
    calculation_start_at = Time.now

    Group.all_ids.each do |group_id|
      Keyword.calculate_z_scores(group_id, timestamp, interval, limit)
    end
    $logger.notice %{Z-scores calculation for time #{time} done in #{Time.now - calculation_start_at} secs}
  end

  # TODO: add support for interval "week" when saving keyword
  def self.calculate_z_scores(group_id, timestamp, interval, limit = 100)
    beginning_of_interval = Timestamp.new(timestamp).time
    timestamp = beginning_of_interval.to_i

    current_keywords = $redis.zrevrange "groups/#{group_id}/#{interval}/#{timestamp}/keywords", 0, limit - 1, with_scores: true
    current_keywords.each do |keyword, count|
      # Ruby doesn't allow iterate through reverse ordered Range so we start from negative number
      historiacal_counts = (-10..-1).map do |n|
        historiacal_timestamp = (beginning_of_interval + n.send(interval)).to_i
        score = $redis.zscore "groups/#{group_id}/#{interval}/#{historiacal_timestamp}/keywords", keyword
      end

      score = FAZScore.new(0.5, historiacal_counts).score(count)
      $redis.zadd "groups/#{group_id}/#{interval}/#{timestamp}/z-scores", score, keyword
    end
  end

  def save
    $redis.multi do
      $redis.set second_source_id_key, @attributes['source_id']
      $redis.set minute_source_id_key, @attributes['source_id']
      $redis.set hour_source_id_key, @attributes['source_id']
      $redis.set day_source_id_key, @attributes['source_id']
      $redis.set month_source_id_key, @attributes['source_id']
      $redis.set year_source_id_key, @attributes['source_id']

      $redis.zincrby second_interval_key, 1, @attributes['word']
      $redis.zincrby minute_interval_key, 1, @attributes['word']
      $redis.zincrby hour_interval_key, 1, @attributes['word']
      $redis.zincrby day_interval_key, 1, @attributes['word']
      $redis.zincrby month_interval_key, 1, @attributes['word']
      $redis.zincrby year_interval_key, 1, @attributes['word']
    end
  end

  def second_source_id_key
    "groups/#{@attributes['group_id']}/second/#{second_timestamp}/#{@attributes['word']}/source_id"
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

  def second_keywords_key
    "groups/#{@attributes['group_id']}/second/keywords"
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

  def second_interval_key
    "groups/#{@attributes['group_id']}/second/#{second_timestamp}/keywords"
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

  def second_timestamp
    Timestamp.new(@attributes['timestamp']).to_second
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
