require 'time'
require 'koko/tracker/utils'
require 'koko/tracker/defaults'

module Koko
  class Tracker
    class Client
      include Koko::Tracker::Utils

      # public: Creates a new client
      #
      # attrs - Hash
      #           :auth           - String of your authorization key
      #           :max_queue_size - Fixnum of the max calls to remain queued (optional)
      #           :on_error       - Proc which handles error calls from the API
      def initialize attrs = {}
        symbolize_keys! attrs

        @auth = attrs[:auth]
        @options = attrs

        check_auth!
      end

      # public: Track content
      #
      # attrs - Hash (see https://docs.koko.ai/#track-endpoints)
      def track_content attrs
        symbolize_keys! attrs

        timestamp = attrs[:created_at] || Time.now
        check_timestamp! timestamp
        attrs[:created_at] = timestamp.iso8601

        handle_response(Request.new(path: '/track/content').post(@auth, attrs)).body
      end

      # public: Track flag
      #
      # attrs - Hash (see https://docs.koko.ai/#track-endpoints)
      def track_flag attrs
        symbolize_keys! attrs

        timestamp = attrs[:created_at] || Time.now
        check_timestamp! timestamp
        attrs[:created_at] = timestamp.iso8601

        handle_response(Request.new(path: '/track/flag').post(@auth, attrs)).body
      end

      # public: Track moderation
      #
      # attrs - Hash (see https://docs.koko.ai/#track-endpoints)
      def track_moderation attrs
        symbolize_keys! attrs

        timestamp = attrs[:created_at] || Time.now
        check_timestamp! timestamp
        attrs[:created_at] = timestamp.iso8601

        handle_response(Request.new(path: '/track/moderation').post(@auth, attrs)).body
      end

      private

      # private: Checks that the auth is properly initialized
      def check_auth!
        fail ArgumentError, 'Auth must be initialized' if @auth.nil?
      end

      # private: Ensure response is valid
      def handle_response(response)
        unless response.valid?
          if response.status >= 400 && response.status < 500
            raise ArgumentError.new("Invalid request: #{response.body}")
          elsif response.status >= 500 && response.status < 600
            raise RuntimeError.new(response.body)
          else
            raise RuntimeError.new("Unaccepted http code: #{response.status}")
          end
        end

        response
      end

      # private: Checks the timstamp option to make sure it is a Time.
      def check_timestamp!(timestamp)
        fail ArgumentError, 'Timestamp must be a Time' unless timestamp.is_a? Time
      end
    end
  end
end
