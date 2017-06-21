require 'koko/tracker/defaults'
require 'koko/tracker/utils'
require 'koko/tracker/defaults'
require 'koko/tracker/request'

module Koko
  class Tracker
    class Worker
      include Koko::Tracker::Utils

      # public: Creates a new worker
      #
      # The worker continuously takes messages off the queue
      # and makes requests to the segment.io api
      #
      # queue   - Queue synchronized between client and worker
      # auth  - String of the project's authorization token
      # options - Hash of worker options
      #           on_error   - Proc of what to do on an error
      #
      def initialize(queue, auth, options = {})
        symbolize_keys! options
        @queue = queue
        @auth = auth
        @on_error = options[:on_error] || Proc.new { |status, error| }
        @batch = []
        @lock = Mutex.new
      end

      # public: Continuously runs the loop to check for new events
      #
      def run
        until Thread.current[:should_exit]
          return if @queue.empty?

          # Batch size of 1 as api doesn't support batching yet
          @batch << @queue.pop

          res = @lock.synchronize do
            request = @batch.first
            Request.new(path: request[:path]).post(@auth, request[:body])
          end

          unless res.status == 200
            @on_error.call res.status, res.body
          end
          @lock.synchronize { @batch.clear }
        end
      end

      def sync(request)
        Request.new(path: request[:path]).post(@auth, request[:body])
      end

      # public: Check whether we have outstanding requests.
      #
      def is_requesting?
        @lock.synchronize { @batch.any? }
      end
    end
  end
end
