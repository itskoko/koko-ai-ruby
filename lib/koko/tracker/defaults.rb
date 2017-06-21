module Koko
  class Tracker
    module Defaults
      module Request
        HOST = 'api.koko.ai'
        PORT = 443
        PATH = '/'
        SSL = true
        HEADERS = { :accept => 'application/json' }
        RETRIES = 4
        BACKOFF = 30.0
      end

      module Queue
        BATCH_SIZE = 10
        MAX_SIZE = 10000
      end
    end
  end
end
