module Pact
  module Consumer
    module RSpec
      def assuming_a_service(name)
        FileUtils.mkdir_p PACTS_PATH
        pactfile_path = File.join(PACTS_PATH, "#{name.downcase}.json")
        MockProducer.new(name, pactfile_path)
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
