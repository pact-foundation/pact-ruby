require 'open-uri'
require 'rspec'
require 'rspec/core'
require 'rspec/core/formatters/progress_formatter'
require_relative 'rspec'

module Pact
	module Producer
		class PactSpecRunner
			def self.run(consumer_expectations, options = {})

				consumer_expectations.each do | consumer_expectation |
					require consumer_expectation[:support_file]
					describe "Pact in #{consumer_expectation[:uri]}" do
						open(consumer_expectation[:uri]) do | file |
							honour_pact JSON.load(file.read)
						end
					end
				end

				config = ::RSpec.configuration
				config.color = true

				unless options[:silent]
					config.error_stream = $stderr
					config.output_stream = $stdout
				end

				formatter = ::RSpec::Core::Formatters::ProgressFormatter.new(config.output)
				reporter =  ::RSpec::Core::Reporter.new(formatter)
				config.instance_variable_set(:@reporter, reporter)

				config.reporter.report(::RSpec::world.example_count, nil) do |reporter|
				  begin
				    config.run_hook(:before, :suite)
				    ::RSpec::world.example_groups.ordered.map {|g| g.run(reporter)}.all? ? 0 : config.failure_exit_code
				  ensure
				    config.run_hook(:after, :suite)
				  end
				end
			end
		end
	end
end