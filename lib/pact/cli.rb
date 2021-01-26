require 'thor'
require 'pact/consumer/configuration'
require 'pact/provider/configuration'

module Pact
  class CLI < Thor
    def self.exit_on_failure? # Thor 1.0 deprecation guard
      false
    end

    desc 'verify', "Verify a pact"
    method_option :pact_helper, aliases: "-h", desc: "Pact helper file", :required => true
    method_option :pact_uri, aliases: "-p", desc: "Pact URI"
    method_option :ignore_failures, type: :boolean, default: false, desc: "Process will always exit with exit code 0", hide: true
    method_option :pact_broker_username, aliases: "-u", desc: "Pact broker user name"
    method_option :pact_broker_password, aliases: "-w", desc: "Pact broker password"
    method_option :pact_broker_token, aliases: "-k", desc: "Pact broker token"
    method_option :backtrace, aliases: "-b", desc: "Show full backtrace", :default => false, :type => :boolean
    method_option :verbose, aliases: "-v", desc: "Show verbose HTTP logging", :default => false, :type => :boolean
    method_option :interactions_replay_order, aliases: "-o",
                  desc: "Interactions replay order: randomised or recorded (default)",
                  default: Pact.configuration.interactions_replay_order
    method_option :description, aliases: "-d", desc: "Interaction description filter"
    method_option :provider_state, aliases: "-s", desc: "Provider state filter"
    method_option :interaction_index, type: :numeric, desc: "Index filter"
    method_option :pact_broker_interaction_id, desc: "Pact Broker interaction ID filter"
    method_option :format, aliases: "-f", banner: "FORMATTER", desc: "RSpec formatter. Defaults to custom Pact formatter. [j]son may also be used."
    method_option :out, aliases: "-o", banner: "FILE", desc: "Write output to a file instead of $stdout."

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
