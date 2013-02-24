class Timestamp
  def initialize(timestamp)
    @timestamp = timestamp
  end

  def to_minute
    @timestamp.to_s[0..11]
  end

  def to_hour
    @timestamp.to_s[0..9]
  end

  def to_day
    @timestamp.to_s[0..7]
  end

  def to_month
    @timestamp.to_s[0..5]
  end

  def to_year
    @timestamp.to_s[0..3]
  end
end
