require 'spec_helper'
require 'pact/producer/configuration_dsl'

module Pact::Producer
  describe ConfigurationDSL do

    class MockConfig
      include ConfigurationDSL
    end

    describe "producer" do
      let(:mock_config) { MockConfig.new }
      before do
        mock_config.producer do
          name "Fred"
          app { "An app" }
        end
      end
      it "should allow configuration of the name" do
        expect(mock_config.producer.name).to eql "Fred"
      end
      it "should allow configuration of the test app" do
        expect(mock_config.producer.app).to eql "An app"
      end
    end


    module ConfigurationDSL
      describe ProducerConfig do
        describe "app" do
          subject { ProducerConfig.new("blah") { Object.new } }
          it "should execute the app_block each time" do
            expect(subject.app.object_id).to_not equal(subject.app.object_id)
          end
        end
      end
    end
  end
end