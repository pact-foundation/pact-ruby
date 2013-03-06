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

#Pact::Consumer::AppManager.instance.register(Pact::Consumer::MockService.new, Pact::Consumer::AppManager.instance.mock_port)
#RSpec.configure do |c|
#  c.before(:all, :type => :feature) do
#    Pact::Consumer::AppManager.instance.spawn_all
#  end
#end
#
#RSpec.configure do |c|
#  # After the tests run, kill the spawned apps
#  c.after(:all, :type => :feature) do
#    Pact::Consumer::AppManager.instance.kill_all
#  end
#end
