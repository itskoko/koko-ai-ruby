require 'koko/tracker/defaults'
require 'koko/tracker/utils'
require 'koko/tracker/response'
require 'koko/tracker/logging'
require 'net/http'
require 'net/https'
require 'json'

module Koko
  class Tracker
    class Request
      include Koko::Tracker::Utils
      include Koko::Tracker::Logging

      attr_reader :http

      # public: Creates a new request object to send analytics batch
      #
      def initialize(options = {})
        options[:host] ||= Defaults::Request.host
        options[:port] ||= Defaults::Request.port
        options[:ssl] ||= Defaults::Request.ssl
        options[:headers] ||= Defaults::Request.headers
        @path = options[:path] || Defaults::Request.path
        @retries = options[:retries] || Defaults::Request.retries
        @backoff = options[:backoff] || Defaults::Request.backoff

        http = Net::HTTP.new(options[:host], options[:port])
        http.use_ssl = options[:ssl]
        http.read_timeout = 8
        http.open_timeout = 4

        @http = http
      end

      # public: Posts the write key and batch of messages to the API.
      #
      # returns - Response of the status and error if it exists
      def post(auth, body)
        status, error = nil, nil
        remaining_retries = @retries + 1
        backoff = @backoff
        headers = { 'Content-Type' => 'application/json' }
        begin
          payload = JSON.generate body
          request = Net::HTTP::Post.new(@path, headers)
          request['authorization'] = auth

          if self.class.stub
            status = 200
            error = nil
            logger.debug "stubbed request to #{@path}: auth = #{auth}, payload = #{payload}"
          else
            res = @http.request(request, payload)
            status = res.code.to_i
            if status < 500
              body = JSON.parse(res.body)
            else
              raise res.body
            end
          end
        rescue Exception => e
          unless (remaining_retries -=1).zero?
            sleep(backoff)
            retry
          end

          logger.error e.message
          e.backtrace.each { |line| logger.error line }
          status = -1
          body = "Connection error: #{e}"
        end

        Response.new status, body
      end

      class << self
        attr_accessor :stub

        def stub
          @stub || ENV['STUB']
        end
      end
    end
  end
end
