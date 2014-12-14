require 'thor'
require 'pact/cli/run_pact_verification'

module Pact
  class CLI < Thor

    desc 'verify', "Verify a pact"
    method_option :pact_helper, aliases: "-h", desc: "Pact helper file", :required => true
    method_option :pact_uri, aliases: "-p", desc: "Pact URI"
    method_option :backtrace, aliases: "-b", desc: "Show full backtrace", :default => false, :type => :boolean

    def verify
      Cli::RunPactVerification.call(options)
    end

  end
end
