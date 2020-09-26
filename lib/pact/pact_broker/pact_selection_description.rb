module Pact
  module PactBroker
    module PactSelectionDescription
      def pact_selection_description(provider, consumer_version_selectors, options, broker_base_url)
        latest = consumer_version_selectors.any? ? "" : "latest "
        message = "Fetching pacts for #{provider} from #{broker_base_url} with the selection criteria: "
        if consumer_version_selectors.any?
          desc = consumer_version_selectors.collect do |selector|
            all_or_latest = !selector[:latest] ? "all for tag" : "latest for tag"
            fallback = selector[:fallback] || selector[:fallbackTag]
            name = fallback ? "#{selector[:tag]} (or #{fallback} if not found)" : selector[:tag]
            "#{all_or_latest} #{name}"
          end.join(", ")
          if options[:include_wip_pacts_since]
            desc = "#{desc}, work in progress pacts created after #{options[:include_wip_pacts_since]}"
          end
          message << "#{desc}"
        end
        message
      end
    end
  end
end
