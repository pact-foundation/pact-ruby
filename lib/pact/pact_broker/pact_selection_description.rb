module Pact
  module PactBroker
    module PactSelectionDescription
      def pact_selection_description(provider, consumer_version_selectors, options, broker_base_url)
        message = "Fetching pacts for #{provider} from #{broker_base_url} with the selection criteria: "
        if consumer_version_selectors.any?
          desc = consumer_version_selectors.collect do |selector|
            desc = nil
            if selector[:tag]
              desc = !selector[:latest] ? "all for tag #{selector[:tag]}" : "latest for tag #{selector[:tag]}"
              desc = "#{desc} of #{selector[:consumer]}" if selector[:consumer]
            elsif selector[:branch]
              desc = "latest from branch #{selector[:branch]}"
              desc = "#{desc} of #{selector[:consumer]}" if selector[:consumer]
            elsif selector[:mainBranch]
              desc = "latest from main branch"
              desc = "#{desc} of #{selector[:consumer]}" if selector[:consumer]
            elsif selector[:deployed]
              if selector[:environment]
                desc = "currently deployed to #{selector[:environment]}"
              else
                desc = "currently deployed"
              end
              desc = "#{selector[:consumer]} #{desc}" if selector[:consumer]
            elsif selector[:released]
              if selector[:environment]
                desc = "currently released to #{selector[:environment]}"
              else
                desc = "currently released"
              end
              desc = "#{selector[:consumer]} #{desc}" if selector[:consumer]
            elsif selector[:deployedOrReleased]
              if selector[:environment]
                desc = "currently deployed or released to #{selector[:environment]}"
              else
                desc = "currently deployed or released"
              end
              desc = "#{selector[:consumer]} #{desc}" if selector[:consumer]
            elsif selector[:environment]
              desc = "currently in #{selector[:environment]}"
              desc = "#{selector[:consumer]} #{desc}" if selector[:consumer]
            elsif selector[:matchingBranch]
              desc = "matching current branch"
              desc = "#{desc} for #{selector[:consumer]}" if selector[:consumer]
            elsif selector[:matchingTag]
              desc = "matching tag"
              desc = "#{desc} for #{selector[:consumer]}" if selector[:consumer]
            else
              desc = selector.to_s
            end

            fallback = selector[:fallback] || selector[:fallbackTag]
            desc = "#{desc} (or #{fallback} if not found)" if fallback

            desc
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
