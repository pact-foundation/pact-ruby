require_relative '../configuration'
require_relative 'app_manager'

module Pact
  module Consumer
    module RSpec

      def consumer(name)
        FileUtils.mkdir_p Pact.configuration.pacts_path
        MockProducer.new(Pact.configuration.pacts_path).consumer(name)
      end

    end
  end
end

RSpec.configure do |c|
  c.include Pact::Consumer::RSpec, :pact => true

  c.after :all, :pact => true do
    Pact::Consumer::AppManager.instance.kill_all
  end
end
