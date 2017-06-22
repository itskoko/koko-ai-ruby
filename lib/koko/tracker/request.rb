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
        status = nil
        headers = { 'Content-Type' => 'application/json' }

        begin
          payload = JSON.generate body
          request = Net::HTTP::Post.new(@path, headers)
          request['authorization'] = auth

          response = nil

          if self.class.stub
            status = 200
            logger.debug "stubbed request to #{@path}: auth = #{auth}, payload = #{payload}"
          else
            res = @http.request(request, payload)
            status = res.code.to_i
            if status < 500
              response = JSON.parse(res.body)
            else
              response = res.body
            end
          end
        rescue Exception => e
          logger.error e.message
          e.backtrace.each { |line| logger.error line }
          status = -1
          response = "Connection error: #{e}"
        end

        Response.new status, response
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
