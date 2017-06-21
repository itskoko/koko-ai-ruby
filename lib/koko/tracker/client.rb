require 'thread'
require 'time'
require 'koko/tracker/utils'
require 'koko/tracker/worker'
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

        @queue = Queue.new
        @auth = attrs[:auth]
        @max_queue_size = attrs[:max_queue_size] || Defaults::Queue::MAX_SIZE
        @options = attrs
        @worker_mutex = Mutex.new
        @worker = Worker.new @queue, @auth, @options

        check_auth!

        at_exit { @worker_thread && @worker_thread[:should_exit] = true }
      end

      # public: Synchronously waits until the worker has flushed the queue.
      #         Use only for scripts which are not long-running, and will
      #         specifically exit
      #
      def flush
        while !@queue.empty? || @worker.is_requesting?
          ensure_worker_running
          sleep(0.1)
        end
      end

      # public: Track content
      #
      # attrs - Hash (see https://docs.koko.ai/#track-endpoints)
      def track_content attrs
        symbolize_keys! attrs

        event = attrs[:event]
        properties = attrs[:properties] || {}
        timestamp = attrs[:timestamp] || Time.new
        context = attrs[:context] || {}
        message_id = attrs[:message_id].to_s if attrs[:message_id]

        check_timestamp! timestamp

        if event.nil? || event.empty?
          fail ArgumentError, 'Must supply event as a non-empty string'
        end

        fail ArgumentError, 'Properties must be a Hash' unless properties.is_a? Hash
        isoify_dates! properties

        add_context context

        enqueue({
          :event => event,
          :userId => attrs[:user_id],
          :anonymousId => attrs[:anonymous_id],
          :context => context,
          :options => attrs[:options],
          :integrations => attrs[:integrations],
          :properties => properties,
          :messageId => message_id,
          :timestamp => datetime_in_iso8601(timestamp),
          :type => 'track'
        })
      end

      # public: Returns the number of queued messages
      #
      # returns Fixnum of messages in the queue
      def queued_messages
        @queue.length
      end

      private

      # private: Enqueues the action.
      #
      # returns Boolean of whether the item was added to the queue.
      def enqueue(action)
        # add our request id for tracing purposes
        action[:messageId] ||= uid
        unless queue_full = @queue.length >= @max_queue_size
          ensure_worker_running
          @queue << action
        end
        !queue_full
      end

      # private: Adds contextual information to the call
      #
      # context - Hash of call context
      def add_context(context)
        context[:library] =  { :name => "koko-ai-ruby", :version => Koko::Tracker::VERSION.to_s }
      end

      # private: Checks that the auth is properly initialized
      def check_auth!
        fail ArgumentError, 'Auth must be initialized' if @auth.nil?
      end

      # private: Checks the timstamp option to make sure it is a Time.
      def check_timestamp!(timestamp)
        fail ArgumentError, 'Timestamp must be a Time' unless timestamp.is_a? Time
      end

      def ensure_worker_running
        return if worker_running?
        @worker_mutex.synchronize do
          return if worker_running?
          @worker_thread = Thread.new do
            @worker.run
          end
        end
      end

      def worker_running?
        @worker_thread && @worker_thread.alive?
      end
    end
  end
end
