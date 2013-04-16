module Pact
  module Consumer
    module RSpec

      def consumer(name)
        FileUtils.mkdir_p PACTS_PATH
        MockProducer.new(PACTS_PATH).consumer(name)
      end

    end
  end
end

RSpec.configure do |c|
  c.include Pact::Consumer::RSpec
end
