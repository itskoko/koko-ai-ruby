module Koko
  class Tracker
    class Response
      attr_reader :status, :body

      # public: Simple class to wrap responses from the API
      #
      #
      def initialize(status = 200, body = nil)
        @status = status
        @body  = body
      end

      def valid?
        @status >= 200 && @status < 300
      end
    end
  end
end

