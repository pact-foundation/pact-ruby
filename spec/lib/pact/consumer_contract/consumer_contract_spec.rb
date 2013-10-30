require 'spec_helper'
require 'pact/consumer_contract'

module Pact
  describe ConsumerContract do
    describe "as_json" do

      class MockInteraction
        def as_json(options ={})
          {:mock => "interaction"}
        end
      end

      def silence_warnings
        old_verbose, $VERBOSE = $VERBOSE, nil
        yield
      ensure
        $VERBOSE = old_verbose
      end

      before do
        @backup_version = Pact::VERSION
        silence_warnings do
          Pact::VERSION = "1.0"
        end
        DateTime.stub(:now).and_return(DateTime.strptime("2013-08-15T13:27:13+10:00"))
      end

      let(:service_consumer) { double('ServiceConsumer', :as_json => {:a => 'consumer'}) }
      let(:service_provider) { double('ServiceProvider', :as_json => {:a => 'provider'}) }
      let(:pact) { ConsumerContract.new({:interactions => [MockInteraction.new], :consumer => service_consumer, :provider => service_provider }) }
      let(:expected_as_json) { {:provider=>{:a=>"provider"}, :consumer=>{:a=>"consumer"}, :interactions=>[{:mock=>"interaction"}], :metadata=>{:pact_gem=>{:version=>"1.0"}}} }

      it "should return a hash representation of the Pact" do
        pact.as_json.should eq expected_as_json
      end

      after do
        silence_warnings do
          Pact::VERSION = @backup_version
        end
      end
    end

    describe ".from_json" do
      let(:loaded_pact) { ConsumerContract.from_json(string) }
      context "when the top level object is a ConsumerContract" do
        let(:string) { '{"interactions":[{"request": {"path":"/path", "method" : "get"}}], "consumer": {"name" : "Bob"} , "provider": {"name" : "Mary"} }' }

        it "should create a Pact" do
          loaded_pact.should be_instance_of ConsumerContract
        end

        it "should have interactions" do
          loaded_pact.interactions.should be_instance_of Array
        end

        it "should have a consumer" do
          loaded_pact.consumer.should be_instance_of Pact::ServiceConsumer
        end

        it "should have a provider" do
          loaded_pact.provider.should be_instance_of Pact::ServiceProvider
        end
      end

      context "with old 'producer' key" do
        let(:string) { File.read('./spec/support/a_consumer-a_producer.json')}
        it "should create a Pact" do
          loaded_pact.should be_instance_of ConsumerContract
        end

        it "should have interactions" do
          loaded_pact.interactions.should be_instance_of Array
        end

        it "should have a consumer" do
          loaded_pact.consumer.should be_instance_of Pact::ServiceConsumer
        end

        it "should have a provider" do
          loaded_pact.provider.should be_instance_of Pact::ServiceProvider
          loaded_pact.provider.name.should eq "an old producer"
        end

        it "should have a provider_state" do
          loaded_pact.interactions.first.provider_state.should eq 'state one'
        end
      end
    end

    describe "find_interactions" do
      let(:consumer) { double('Pact::ServiceConsumer', :name => 'Consumer')}
      let(:provider) { double('Pact::ServiceProvider', :name => 'Provider')}
      let(:interaction) { double('Pact::Interaction') }
      subject { ConsumerContract.new(:interactions => [interaction], :consumer => consumer, :provider => provider) }
      let(:criteria) { {:description => /blah/} }
      before do
        interaction.should_receive(:matches_criteria?).with(criteria).and_return(matches)
      end
      context "by description" do
        context "when no interactions are found" do
          let(:matches) { false }
          it "returns an empty array" do
            expect(subject.find_interactions(criteria)).to eql []
          end
        end
        context "when interactions are found" do
          let(:matches) { true }
          it "returns an array of the matching interactions" do
            expect(subject.find_interactions(criteria)).to eql [interaction]
          end
        end
      end
    end

    describe "find_interaction" do
      let(:consumer) { double('Pact::ServiceConsumer', :name => 'Consumer')}
      let(:provider) { double('Pact::ServiceProvider', :name => 'Provider')}
      let(:interaction1) { double('Pact::Interaction') }
      let(:interaction2) { double('Pact::Interaction') }
      let(:criteria) { {:description => /blah/} }

      before do
        interaction1.should_receive(:matches_criteria?).with(criteria).and_return(matches1)
        interaction2.should_receive(:matches_criteria?).with(criteria).and_return(matches2)
      end

      subject { ConsumerContract.new(:interactions => [interaction1, interaction2], :consumer => consumer, :provider => provider) }
      context "by description" do
        context "when a match is found" do
          let(:matches1) { true }
          let(:matches2) { false }

          it "returns the interaction" do
            expect(subject.find_interaction criteria).to eql interaction1
          end
        end
        context "when more than one match is found" do
          let(:matches1) { true }
          let(:matches2) { true }
          it "raises an error" do
            expect{ subject.find_interaction(criteria) }.to raise_error "Found more than 1 interaction matching {:description=>/blah/} in pact file between Consumer and Provider."
          end
        end
        context "when a match is not found" do
          let(:matches1) { false }
          let(:matches2) { false }
          it "raises an error" do
            expect{ subject.find_interaction(criteria) }.to raise_error "Could not find interaction matching {:description=>/blah/} in pact file between Consumer and Provider."
          end
        end
      end
    end

    describe "update_pactfile" do
      let(:pacts_dir) { Pathname.new("./tmp/pactfiles") }
      let(:expected_pact_path) { pacts_dir + "test_consumer-test_service.json" }
      let(:expected_pact_string) do <<-eos
{
  "provider": {
    "name": "test_service"
  },
  "consumer": {
    "name": "test_consumer"
  },
  "interactions": [
    "something"
  ],
  "metadata": {
    "pact_gem": {
      "version": "#{Pact::VERSION}"
    }
  }
}
eos
      end
      let(:consumer) { Pact::ServiceConsumer.new(:name => 'test_consumer')}
      let(:provider) { Pact::ServiceProvider.new(:name => 'test_service')}
      let(:interactions) { [double("interaction", as_json: "something")]}
      subject { ConsumerContract.new(:consumer => consumer, :provider => provider, :interactions => interactions) }
      before do
        Pact.configuration.stub(:pact_dir).and_return(Pathname.new("./tmp/pactfiles"))
        FileUtils.rm_rf pacts_dir
        FileUtils.mkdir_p pacts_dir
        subject.update_pactfile
      end

      it "should write to a file specified by the consumer and provider name" do
        File.exist?(expected_pact_path).should be_true
      end

      it "should write the interactions to the file" do
        File.read(expected_pact_path).should eql expected_pact_string.strip
      end
    end
  end
end