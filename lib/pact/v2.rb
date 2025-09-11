# frozen_string_literal: true

require "zeitwerk"
require "pact/ffi"

require "pact/v2/railtie" if defined?(Rails::Railtie)

module Pact
  module V2
    class Error < StandardError; end

    class ImplementationRequired < Error; end

    class FfiError < Error
      def initialize(msg, reason, status)
        super(msg)

        @msg = msg
        @reason = reason
        @status = status
      end

      def message
        "FFI error: reason: #{@reason}, status: #{@status}, message: #{@msg}"
      end
    end

    def self.configure
      yield configuration if block_given?
    end

    def self.configuration
      @configuration ||= Pact::V2::Configuration.new
    end
  end
end

loader = Zeitwerk::Loader.new
puts "LOADER ROOT: #{File.join(__dir__, "..",)}"
loader.push_dir(File.join(__dir__, ".."))

loader.tag = "pact-v2"

# existing pact-ruby ignores
# loader.ignore("#{__dir__}/../pact") # ignore the pact dir at the root of the repo
# loader.ignore("#{__dir__}/../pact/v2",false) # ignore the pact dir at the root of the repo
# loader.push_dir(File.join(__dir__))


loader.ignore("#{__dir__}/../pact/version.rb")
loader.ignore("#{__dir__}/../pact/cli")
loader.ignore("#{__dir__}/../pact/cli.rb")
loader.ignore("#{__dir__}/../pact/consumer")
loader.ignore("#{__dir__}/../pact/consumer.rb")
loader.ignore("#{__dir__}/../pact/doc")
loader.ignore("#{__dir__}/../pact/hal")
loader.ignore("#{__dir__}/../pact/hash_refinements.rb")
loader.ignore("#{__dir__}/../pact/pact_broker")
loader.ignore("#{__dir__}/../pact/pact_broker.rb")
loader.ignore("#{__dir__}/../pact/project_root.rb")
loader.ignore("#{__dir__}/../pact/provider")
loader.ignore("#{__dir__}/../pact/provider.rb")
loader.ignore("#{__dir__}/../pact/retry.rb")
loader.ignore("#{__dir__}/../pact/tasks")
loader.ignore("#{__dir__}/../pact/tasks.rb")
loader.ignore("#{__dir__}/../pact/templates")
loader.ignore("#{__dir__}/../pact/utils")
loader.ignore("#{__dir__}/../pact/v2/rspec.rb")
loader.ignore("#{__dir__}/../pact/v2/rspec")
loader.ignore("#{__dir__}/../pact/v2/railtie.rb") unless defined?(Rails::Railtie)
loader.setup
loader.eager_load


# loader.ignore("#{__dir__}/pact/v2")