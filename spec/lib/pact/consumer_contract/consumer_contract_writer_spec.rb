require 'spec_helper'
require 'pact/consumer_contract/consumer_contract_writer'

module Pact

  describe ConsumerContractWriter do

    let(:support_pact_file) { './spec/support/a_consumer-a_provider.json' }
    let(:consumer_name) { 'a consumer' }
    let(:provider_name) { 'a provider' }

    before do
      Pact.clear_configuration
      allow(Pact.configuration).to receive(:pact_dir).and_return(File.expand_path(tmp_pact_dir))
      FileUtils.rm_rf tmp_pact_dir
      FileUtils.mkdir_p tmp_pact_dir
      FileUtils.cp support_pact_file, "#{tmp_pact_dir}/a_consumer-a_provider.json"
    end

    let(:existing_interactions) { ConsumerContract.from_json(File.read(support_pact_file)).interactions }
    let(:new_interactions) { [InteractionFactory.create] }
    let(:tmp_pact_dir) {"./tmp/pacts"}
    let(:logger) { double("logger").as_null_object }
    let(:pactfile_write_mode) {:overwrite}
    let(:consumer_contract_details) {
      {
          consumer: {name: consumer_name},
          provider: {name: provider_name},
          pactfile_write_mode: pactfile_write_mode,
          interactions: new_interactions
      }
    }

    let(:consumer_contract_writer) { ConsumerContractWriter.new(consumer_contract_details, logger) }

    describe "consumer_contract" do

      let(:subject) { consumer_contract_writer.consumer_contract }

      context "when overwriting pact" do

        it "it uses only the interactions from the current test run" do
          expect(consumer_contract_writer.consumer_contract.interactions).to eq new_interactions
        end

      end

      context "when updating pact" do

        let(:pactfile_write_mode) {:update}

        it "merges the interactions from the current test run with the interactions from the existing file" do
          allow_any_instance_of(ConsumerContractWriter).to receive(:info_and_puts)
          expect(consumer_contract_writer.consumer_contract.interactions).to eq  existing_interactions + new_interactions
        end

        let(:line0) { /\*/ }
        let(:line1) { /Updating existing file/ }
        let(:line2) { /Only interactions defined in this test run will be updated/ }
        let(:line3) { /As interactions are identified by description and provider state/ }

        it "logs a description message" do
          expect($stdout).to receive(:puts).with(line0).twice
          expect($stdout).to receive(:puts).with(line1)
          expect($stdout).to receive(:puts).with(line2)
          expect($stdout).to receive(:puts).with(line3)
          expect(logger).to receive(:info).with(line0).twice
          expect(logger).to receive(:info).with(line1)
          expect(logger).to receive(:info).with(line2)
          expect(logger).to receive(:info).with(line3)
          consumer_contract_writer.consumer_contract
        end
      end

      context "when an error occurs deserializing the existing pactfile" do

        let(:pactfile_write_mode) {:update}
        let(:error) { RuntimeError.new('some error')}
        let(:line1) { /Could not load existing consumer contract from .* due to some error/ }
        let(:line2) {'Creating a new file.'}

        before do
          allow(ConsumerContract).to receive(:from_json).and_raise(error)
          allow($stderr).to receive(:puts)
          allow(logger).to receive(:puts)
        end

        it "logs the error" do
          expect($stderr).to receive(:puts).with(line1)
          expect($stderr).to receive(:puts).with(line2)
          expect(logger).to receive(:warn).with(line1)
          expect(logger).to receive(:warn).with(line2)
          consumer_contract_writer.consumer_contract
        end

        it "uses the new interactions" do
          expect(consumer_contract_writer.consumer_contract.interactions).to eq new_interactions
        end
      end
    end

    describe "write" do
      it "writes the pact file" do
        expect_any_instance_of(ConsumerContract).to receive(:update_pactfile)
        consumer_contract_writer.write
      end
    end

  end

end