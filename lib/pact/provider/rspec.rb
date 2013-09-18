require 'open-uri'
require 'pact/consumer_contract'
require 'pact/json_warning'
require 'pact/provider/matchers'
require 'pact/provider/test_methods'
require 'pact/provider/configuration'

module Pact
  module Provider
    module RSpec

      module InstanceMethods
        def app
          Pact.configuration.provider.app
        end
      end

      module ClassMethods

        include ::RSpec::Core::DSL

        include Pact::JsonWarning

        def honour_pactfile pactfile_uri, options = {}
          describe "Pact in #{pactfile_uri}" do
            consumer_contract = Pact::ConsumerContract.from_json(read_pact_from(pactfile_uri, options))
            honour_consumer_contract consumer_contract, options
          end
        end

        def honour_consumer_contract consumer_contract, options = {}
          check_for_active_support_json
          describe_consumer_contract consumer_contract, options.merge({:consumer => consumer_contract.consumer.name})
        end

        private

        def describe_consumer_contract consumer_contract, options
          consumer_contract.interactions.each do |interaction|
            describe_interaction_with_provider_state interaction, options
          end
        end

        def describe_interaction_with_provider_state interaction, options
          if interaction.provider_state
            describe "Given #{interaction.provider_state}" do
              describe_interaction interaction, options
            end
          else
            describe_interaction interaction, options
          end
        end

        def describe_interaction interaction, options

          describe description_for(interaction) do

            before do
              set_up_provider_state interaction.provider_state, options[:consumer]
              replay_interaction interaction
            end

            after do
              tear_down_provider_state interaction.provider_state, options[:consumer]
            end

            describe_response interaction.response
          end

        end

        def describe_response response
          describe "returns a response which" do
            if response['status']
              it "has status code #{response['status']}" do
                expect(last_response.status).to eql response['status']
              end
            end

            if response['headers']
              describe "includes headers" do
                response['headers'].each do |name, value|
                  it "\"#{name}\" with value \"#{value}\"" do
                    expect(last_response.headers[name]).to match_term value
                  end
                end
              end
            end

            if response['body']
              it "has a matching body" do
                logger.debug "Response body is #{last_response.body}"
                expect(parse_body_from_response(last_response)).to match_term response['body']
              end
            end
          end
        end

        def description_for interaction
          "#{interaction.description} to #{interaction.request.path}"
        end

        def read_pact_from uri, options = {}
          pact = open(uri) { | file | file.read }
          if options[:save_pactfile_to_tmp]
            save_pactfile_to_tmp pact, File.basename(uri)
          end
          pact
        rescue StandardError => e
          $stderr.puts "Error reading file from #{uri}"
          $stderr.puts "#{e.to_s} #{e.backtrace.join("\n")}"
          raise e
        end

        def save_pactfile_to_tmp pact, name
          FileUtils.mkdir_p Pact.configuration.tmp_dir
          File.open(Pact.configuration.tmp_dir + "/#{name}", "w") { |file|  file << pact}
        end

      end
    end
  end
end

RSpec.configure do |config|
  config.extend Pact::Provider::RSpec::ClassMethods
  config.include Pact::Provider::RSpec::InstanceMethods
  config.include Pact::Provider::TestMethods
end
