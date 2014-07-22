module Pact

  class Response < Hash

    def initialize hash = {}
      self.merge!(hash) unless hash.nil?
    end

    def status
      ['status']
    end

    def body
      ['body']
    end

    def headers
      ['headers']
    end

  end

end