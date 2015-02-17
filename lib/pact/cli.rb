require 'thor'
require 'pact/cli/run_pact_verification'
require 'pact/cli/generate_pact_docs'

module Pact
  class CLI < Thor

    desc 'verify', "Verify a pact"
    method_option :pact_helper, aliases: "-h", desc: "Pact helper file", :required => true
    method_option :pact_uri, aliases: "-p", desc: "Pact URI"
    method_option :backtrace, aliases: "-b", desc: "Show full backtrace", :default => false, :type => :boolean
    method_option :description, aliases: "-d", desc: "Interaction description filter"
    method_option :provider_state, aliases: "-s", desc: "Provider state filter"

    def verify
      Cli::RunPactVerification.call(options)
    end

    desc 'docs', "Generate pact documentation"
    def docs
      Pact::Doc::Generate.call('./pacts', './doc/pacts', [Pact::Doc::Markdown::Generator])
    end

  end
end
