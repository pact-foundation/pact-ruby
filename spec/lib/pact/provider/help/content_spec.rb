require 'pact/provider/help/content'

module Pact
  module Provider
    module Help
      describe Content do

        describe "#text" do

          let(:pact_1_json) { {some: 'json'}.to_json }
          let(:pact_2_json) { {some: 'other json'}.to_json }
          let(:pact_jsons) { [pact_1_json, pact_2_json] }

          before do
            allow(PactDiff).to receive(:call).with(pact_1_json).and_return('diff 1')
            allow(PactDiff).to receive(:call).with(pact_2_json).and_return(nil)
          end

          subject { Content.new(pact_jsons) }

          it "displays the log path" do
            expect(subject.text).to include Pact.configuration.log_path
          end

          it "displays the tmp dir" do
            expect(subject.text).to include Pact.configuration.tmp_dir
          end

          it "displays the diff" do
            expect(subject.text).to include 'diff 1'
          end

        end
      end
    end
  end
end
