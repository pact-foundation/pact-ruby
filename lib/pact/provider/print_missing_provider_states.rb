module Pact
  module Provider
    class PrintMissingProviderStates

      # Hash of consumer names to array of names of missing provider states
      def self.call missing_provider_states, output
        if missing_provider_states.any?
          output.puts orangeify(text(missing_provider_states))
        end
      end

      def self.orangeify string
        "\e[33m#{string}\e[m"
      end

      def self.text missing_provider_states
        create_provider_states_for(missing_provider_states)
      end

      def self.create_provider_states_for consumers
        ERB.new(template_string).result(binding)
      end

      def self.template_string
        File.read(File.expand_path( '../../templates/provider_state.erb', __FILE__))
      end

    end
  end
end