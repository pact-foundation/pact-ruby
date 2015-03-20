require 'thor'
require 'pact/consumer/configuration'

module Pact
  class CLI < Thor

    desc 'verify', "Verify a pact"
    method_option :pact_helper, aliases: "-h", desc: "Pact helper file", :required => true
    method_option :pact_uri, aliases: "-p", desc: "Pact URI"
    method_option :pact_broker_username, aliases: "-u", desc: "Pact broker user name"
    method_option :pact_broker_password, aliases: "-w", desc: "Pact broker password"
    method_option :backtrace, aliases: "-b", desc: "Show full backtrace", :default => false, :type => :boolean
    method_option :description, aliases: "-d", desc: "Interaction description filter"
    method_option :provider_state, aliases: "-s", desc: "Provider state filter"

    def verify
      require 'pact/cli/run_pact_verification'
      Cli::RunPactVerification.call(options)
    end

    desc 'docs', "Generate Pact documentation in markdown"
    method_option :pact_dir, desc: "Directory containing the pacts", default: Pact.configuration.pact_dir
    method_option :doc_dir, desc: "Documentation directory", default: Pact.configuration.doc_dir

    def docs
      require 'pact/cli/generate_pact_docs'
      require 'pact/doc/generator'
      Pact::Doc::Generate.call(options[:pact_dir], options[:doc_dir], [Pact::Doc::Markdown::Generator])
    end

  end
end
