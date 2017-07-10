Bundler.require

require 'active_support/time'
require 'webmock/rspec'
require 'timecop'
require 'pry'

# Setting timezone for ActiveSupport::TimeWithZone to UTC
Time.zone = 'UTC'

module Koko
  class Tracker
    module Factory
      def self.content
        {
          "id" => "123",
          "created_at" => Time.at(1498070225),
          "user_id" => "123",
          "type" => "post",
          "context_id" => "123",
          "content_type" => "text",
          "content" => { "text" => "Some content" }
        }.clone
      end

      def self.flag
        {
          "id" => "123",
          "flagger_id" => "123",
          "type" => "spam",
          "created_at" => Time.at(1498070225),
          "content" => { "id" => "123" }
        }.clone
      end

      def self.moderation
        {
          "id" => "123",
          "moderator_id" => "123",
          "type" => "user_warned",
          "created_at" => Time.at(1498070225),
          "content" => { "id" => "123" }
        }
      end

      def self.behavorial_classification
        {
          "classifiers" => {
            "id" =>  "123",
            "classification": [
              {
                "label" => "crisis",
                "confidence" => 0.95
              }
            ]
          }
        }
      end
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
