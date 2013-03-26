# coding: utf-8
class Crontab < Base
  def fetch_and_save
    result = []
    %w(second minute hour day month year).each do |interval|
      last_timestamp = $redis.get "crontabs/last_#{interval}"
      # gets the string formatted timestamp cutted to the interval
      # example of hour timestamp: 2013-01-01T01
      current_timestamp = Timestamp.new(@attributes["timestamp"]).send("to_#{interval}")
      
      # now we're comparing the last (currently processing) timestamp to the actual
      # time right now and seeing if we're ready to summarize the results
      # is the currently processed time period elapsed?
      if current_timestamp != last_timestamp
        result += Group.new("id" => @attributes["group_id"]).trends(interval, last_timestamp.to_i + 1, current_timestamp) if last_timestamp
        $redis.set "crontabs/last_#{interval}", current_timestamp
      end
    end
    result
  end
end
