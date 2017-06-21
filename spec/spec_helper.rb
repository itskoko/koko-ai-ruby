require 'koko/tracker'
require 'active_support/time'

# Setting timezone for ActiveSupport::TimeWithZone to UTC
Time.zone = 'UTC'

module Koko
  class Tracker
    module Factory

      Content = {
        :event => 'Ruby Library test event',
        :properties => {
          :type => 'Chocolate',
          :is_a_lie => true,
          :layers => 20,
          :created =>  Time.new
        }
      }

    end
  end
end

# usage:
# it "should return a result of 5" do
#   eventually(options: {timeout: 1}) { long_running_thing.result.should eq(5) }
# end

module AsyncHelper
  def eventually(options = {})
    timeout = options[:timeout] || 5 #seconds
    interval = options[:interval] || 0.25 #seconds
    time_limit = Time.now + timeout
    loop do
      begin
        yield
      rescue => error
      end
      return if error.nil?
      raise error if Time.now >= time_limit
      sleep interval
    end
  end
end

include AsyncHelper
