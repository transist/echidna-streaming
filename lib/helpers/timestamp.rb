class Timestamp
  def initialize(timestamp)
    @timestamp = timestamp
  end

  def to_minute
    @timestamp.to_s[0..15]
  end

  def to_hour
    @timestamp.to_s[0..12]
  end

  def to_day
    @timestamp.to_s[0..9]
  end

  def to_month
    @timestamp.to_s[0..6]
  end

  def to_year
    @timestamp.to_s[0..3]
  end

  def to_minute_int
    to_minute.gsub(/[^\d]/, '')
  end

  def to_hour_int
    to_hour.gsub(/[^\d]/, '')
  end

  def to_day_int
    to_day.gsub(/[^\d]/, '')
  end

  def to_month_int
    to_month.gsub(/[^\d]/, '')
  end

  def to_year_int
    to_year
  end
end
