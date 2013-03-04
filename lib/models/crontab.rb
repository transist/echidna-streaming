# coding: utf-8
class Crontab < Base
  def fetch_and_save
    result = {}
    %w(minute hour day month year).each do |interval|
      last_timestamp = $redis.get "crontabs/last_#{interval}"
      current_timestamp = Timestamp.new(@attributes["timestamp"]).send("to_#{interval}")
      if current_timestamp != last_timestamp
        result[interval] = Group.new("id" => @attributes["group_id"]).trends(interval, last_timestamp.to_i + 1, current_timestamp) if last_timestamp
        $redis.set "crontabs/last_#{interval}", current_timestamp
      end
    end
    result
  end
end
