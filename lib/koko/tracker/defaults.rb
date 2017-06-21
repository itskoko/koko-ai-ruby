module Koko
  class Tracker
    module Defaults
      module Request
        class << self
          attr_accessor :host, :port, :path, :ssl, :headers, :retries, :backoff
        end

        self.host = 'api.koko.ai'
        self.port = 443
        self.path = '/'
        self.ssl = true
        self.headers = { :accept => 'application/json' }
        self.retries = 4
        self.backoff = 30.0
      end

      module Queue
        class << self
          attr_accessor :max_size
        end

        self.max_size = 10000
      end
    end
  end
end
