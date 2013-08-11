require 'spec_helper'
require 'pact/producer/configuration_dsl'

module Pact::Producer
  describe ConfigurationDSL do

    class MockConfig
      include ConfigurationDSL
    end

    describe "producer" do
      let(:mock_config) { MockConfig.new }
      context "when a producer is configured" do
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
      context "when a producer is not configured" do
        it "raises an error" do
          expect{ mock_config.producer }.to raise_error(/Please configure your producer/)
        end
      end
    end


    module ConfigurationDSL

      describe ProducerDSL do

        describe "initialize" do

          context "with an object instead of a block" do
            subject do
              ProducerDSL.new do
                name nil
                app 'blah'
              end
            end
            it "raises an error" do
              expect{ subject }.to raise_error
            end
          end


        end
        describe "validate" do
          context "when no name is provided" do
            subject do
              ProducerDSL.new do
                app { Object.new }
              end
            end
            it "raises an error" do
              expect{ subject.validate}.to raise_error("Please provide a name for the Producer")
            end
          end
          context "when nil name is provided" do
            subject do
              ProducerDSL.new do
                name nil
                app { Object.new }
              end
            end
            it "raises an error" do
              expect{ subject.validate}.to raise_error("Please provide a name for the Producer")
            end
          end
          context "when no app is provided" do
            subject do
              ProducerDSL.new do
                name 'Blah'
              end
            end
            it "raises an error" do
              expect{ subject.validate }.to raise_error("Please configure an app for the Producer")
            end
          end
        end
      end

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
