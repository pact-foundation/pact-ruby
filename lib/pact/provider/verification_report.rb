require 'pact/consumer_contract'

module Pact::Provider
  class VerificationReport

    include Pact::FileName

    def initialize (options)
      @consumer = options[:consumer]
      @provider = options[:provider]
      @result = options[:result]
      @output = options[:output]
    end

    def to_hash
      {
        :consumer => @consumer,
        :provider => @provider,
        :result => @result,
        :output => @output
      }
    end

    def as_json options = {}
      to_hash
    end

    def to_json(options = {})
      as_json.to_json(options)
    end

    def report_file_name
      file_name("#{@consumer[:name]}_#{@consumer[:ref]}", "#{@provider[:name]}_#{@provider[:ref]}")
    end
  end
end
