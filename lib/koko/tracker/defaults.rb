module Koko
  class Tracker
    module Defaults
      module Request
        class << self
          attr_accessor :host, :port, :path, :ssl, :headers
        end

        self.host = 'api.koko.ai'
        self.port = 443
        self.path = '/'
        self.ssl = true
        self.headers = { :accept => 'application/json' }
      end
    end
  end
end
