require 'pact/configuration'
require 'pact/provider/pact_helper_locator'
require 'rake/file_utils'
require 'shellwords'

module Pact
  module TaskHelper

    PACT_INTERACTION_RERUN_COMMAND = "bundle exec rake pact:verify:at[<PACT_URI>] PACT_DESCRIPTION=\"<PACT_DESCRIPTION>\" PACT_PROVIDER_STATE=\"<PACT_PROVIDER_STATE>\""
    PACT_INTERACTION_RERUN_COMMAND_FOR_BROKER = "bundle exec rake pact:verify:at[<PACT_URI>] PACT_BROKER_INTERACTION_ID=\"<PACT_BROKER_INTERACTION_ID>\""

    extend self

    def execute_pact_verify pact_uri = nil, pact_helper = nil, rspec_opts = nil, verification_opts = {}
      execute_cmd verify_command(pact_helper || Pact::Provider::PactHelperLocater.pact_helper_path, pact_uri, rspec_opts, verification_opts)
    end

    def handle_verification_failure
      exit_status = yield
      abort if exit_status != 0
    end

    def verify_command pact_helper, pact_uri, rspec_opts, verification_opts
      command_parts = []
      # Clear SPEC_OPTS, otherwise we can get extra formatters, creating duplicate output eg. CI Reporting.
      # Allow deliberate configuration using rspec_opts in VerificationTask.
      command_parts << "SPEC_OPTS=#{Shellwords.escape(rspec_opts || '')}"
      command_parts << FileUtils::RUBY
      command_parts << "-S pact verify"
      command_parts << "--pact-helper" << Shellwords.escape(pact_helper.end_with?(".rb") ? pact_helper : pact_helper + ".rb")
      (command_parts << "--pact-uri" << pact_uri) if pact_uri
      command_parts << "--ignore-failures" if verification_opts[:ignore_failures]
      command_parts << "--pact-broker-username" << ENV['PACT_BROKER_USERNAME'] if ENV['PACT_BROKER_USERNAME']
      command_parts << "--pact-broker-password" << ENV['PACT_BROKER_PASSWORD'] if ENV['PACT_BROKER_PASSWORD']
      command_parts << "--backtrace" if ENV['BACKTRACE'] == 'true'
      command_parts << "--description #{Shellwords.escape(ENV['PACT_DESCRIPTION'])}" if ENV['PACT_DESCRIPTION']
      command_parts << "--provider-state #{Shellwords.escape(ENV['PACT_PROVIDER_STATE'])}" if ENV['PACT_PROVIDER_STATE']
      command_parts << "--pact-broker-interaction-id #{Shellwords.escape(ENV['PACT_BROKER_INTERACTION_ID'])}" if ENV['PACT_BROKER_INTERACTION_ID']
      command_parts << "--interaction-index #{Shellwords.escape(ENV['PACT_INTERACTION_INDEX'])}" if ENV['PACT_INTERACTION_INDEX']
      command_parts.flatten.join(" ")
    end

    def execute_cmd command
      Pact.configuration.output_stream.puts command
      temporarily_set_env_var 'PACT_EXECUTING_LANGUAGE', 'ruby' do
        temporarily_set_env_var 'PACT_INTERACTION_RERUN_COMMAND', PACT_INTERACTION_RERUN_COMMAND do
          temporarily_set_env_var 'PACT_INTERACTION_RERUN_COMMAND_FOR_BROKER', PACT_INTERACTION_RERUN_COMMAND_FOR_BROKER do
            exit_status = system(command) ? 0 : 1
          end
        end
      end
    end

    def temporarily_set_env_var name, value
      original_value = ENV[name]
      ENV[name] ||= value
      yield
    ensure
      ENV[name] = original_value
    end
  end
end
