class Timestamp
  def initialize(timestamp)
    @time = Time.at(timestamp).utc
  end

  def to_minute
    @time.change(sec: 0).to_i
  end

  def to_hour
    @time.beginning_of_hour.to_i
  end

  def to_day
    @time.beginning_of_day.to_i
  end

  def to_month
    @time.beginning_of_month.to_i
  end

  def to_year
    @time.beginning_of_year.to_i
  end

  def to_formatted_minute
    @time.strftime("%Y-%m-%dT%H:%M")
  end

  def to_formatted_hour
    @time.strftime("%Y-%m-%dT%H")
  end

  def to_formatted_day
    @time.strftime("%Y-%m-%d")
  end

  def to_formatted_month
    @time.strftime("%Y-%m")
  end

  def to_formatted_year
    @time.strftime("%Y")
  end
end
