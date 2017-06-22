require 'koko/tracker/defaults'
require 'koko/tracker/utils'
require 'koko/tracker/version'
require 'koko/tracker/client'
require 'koko/tracker/request'
require 'koko/tracker/response'
require 'koko/tracker/logging'

module Koko
  class Tracker
    def initialize options = {}
      Request.stub = options[:stub] if options.has_key?(:stub)
      @client = Koko::Tracker::Client.new options
    end

    def method_missing message, *args, &block
      if @client.respond_to? message
        @client.send message, *args, &block
      else
        super
      end
    end

    def respond_to? method_name, include_private = false
      @client.respond_to?(method_name) || super
    end

    include Logging
  end
end
