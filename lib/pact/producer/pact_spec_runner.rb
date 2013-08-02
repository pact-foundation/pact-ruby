require 'open-uri'
require 'rspec'
require 'rspec/core'
require 'rspec/core/formatters/documentation_formatter'
require_relative 'rspec'
require 'pact/consumer_contract'

module Pact
	module Producer
		class PactSpecRunner

			def self.run(spec_definitions, options = {})
				initialize_specs spec_definitions
				configure_rspec options
				run_specs
			end

			private

			def self.initialize_specs spec_definitions
				spec_definitions.each do | spec_definition |
					pact = read_pact_from spec_definition[:uri]
					describe "Pact in #{spec_definition[:uri]}" do
						require spec_definition[:support_file] if spec_definition[:support_file]
						honour_pact Pact::ConsumerContract.from_json(pact), {consumer: spec_definition[:consumer]}
					end
				end
			end

			def self.read_pact_from uri
				open(uri) { | file | file.read }
			rescue StandardError => e
				$stderr.puts "Error reading file from #{uri}"
				$stderr.puts "#{e.to_s} #{e.backtrace.join("\n")}"
				raise e
			end

			def self.configure_rspec options
				config = ::RSpec.configuration
				config.color = true

				unless options[:silent]
					config.error_stream = $stderr
					config.output_stream = $stdout
				end

				formatter = ::RSpec::Core::Formatters::DocumentationFormatter.new(config.output)
				reporter =  ::RSpec::Core::Reporter.new(formatter)
				config.instance_variable_set(:@reporter, reporter)
			end

			def self.run_specs
				config = ::RSpec.configuration
				world = ::RSpec::world
				config.reporter.report(world.example_count, nil) do |reporter|
				  begin
				    config.run_hook(:before, :suite)
				    world.example_groups.ordered.map {|g| g.run(reporter)}.all? ? 0 : config.failure_exit_code
				  ensure
				    config.run_hook(:after, :suite)
				  end
				end
			end
		end
	end
end