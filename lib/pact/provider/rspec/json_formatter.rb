require 'rspec/core/formatters/json_formatter'

module Pact
  module Provider
    module RSpec
      class JsonFormatter < ::RSpec::Core::Formatters::JsonFormatter
        ::RSpec::Core::Formatters.register self, :message, :dump_summary, :dump_profile, :stop, :seed, :close

        def dump_summary(summary)
          super(create_custom_summary(summary))
          output_hash[:summary][:notices] = pact_broker_notices(summary)
        end

        def format_example(example)
          {
            :id => example.id,
            :description => example.description,
            :full_description => example.full_description,
            :status => calculate_status(example),
            :file_path => example.metadata[:file_path],
            :line_number  => example.metadata[:line_number],
            :run_time => example.execution_result.run_time,
            :mismatches => extract_differences(example)
          }
        end

        def stop(notification)
          output_hash[:examples] = notification.examples.map do |example|
            format_example(example).tap do |hash|
              e = example.exception
              # No point providing a backtrace for a mismatch, too much noise
              if e && ! e.is_a?(::RSpec::Expectations::ExpectationNotMetError)
                hash[:exception] =  {
                  :class => e.class.name,
                  :message => e.message,
                  :backtrace => e.backtrace,
                }
              end
            end
          end
        end

        def calculate_status(example)
          if example.execution_result.status == :failed && example.metadata[:pact_ignore_failures]
            'pending'
          else
            example.execution_result.status.to_s
          end
        end

        # There will most likely be only one pact associated with this RSpec execution, because
        # the most likely user of this formatter is the Go implementation that parses the JSON
        # and builds Go tests from them.
        # If the JSON formatter is used by someone else and they have multiple pacts, all the notices
        # for the pacts will be mushed together in one collection, so it will be hard to know which notice
        # belongs to which pact.
        def pact_broker_notices(summary)
          pact_uris(summary).collect{ |pact_uri| pact_uri.metadata[:notices] }.compact.flatten
        end

        def pact_uris(summary)
          summary.examples.collect(&:metadata).collect{ |metadata| metadata[:pact_uri] }.uniq
        end

        def create_custom_summary(summary)
          ::RSpec::Core::Notifications::SummaryNotification.new(
            summary.duration,
            summary.examples,
            summary.examples.select{ | example | example.execution_result.status == :failed && !example.metadata[:pact_ignore_failures] },
            summary.examples.select{ | example | example.execution_result.status == :failed && example.metadata[:pact_ignore_failures] },
            summary.load_time,
            summary.errors_outside_of_examples_count
          )
        end

        def extract_differences(example)
          if example.metadata[:pact_diff]
            Pact::Matchers::ExtractDiffMessages.call(example.metadata[:pact_diff]).to_a
          else
            []
          end
        end
      end
    end
  end
end
