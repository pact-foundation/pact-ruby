module Pact::Provider
   class Verification
      attr_reader :consumer_name, :uri, :ref, :task
      def initialize consumer_name, uri, ref, task
         @consumer_name = consumer_name
         @uri = uri
         @ref = ref
         @task = task
      end
   end
end