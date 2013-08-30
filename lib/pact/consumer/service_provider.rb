module Pact
  module Consumer
    # This is a crap name, it's really just a object for serializing to JSON
    class ServiceProvider
      attr_accessor :name
      def initialize options
        @name = options[:name] || '[provider name unknown - please update the pact gem in the consumer project to the latest version and regenerate the pacts]'
      end

      def to_s
        name
      end

      def as_json options = {}
        {name: name}
      end

      def self.from_hash obj
        ServiceProvider.new(:name => obj['name'])
      end
    end
  end
end