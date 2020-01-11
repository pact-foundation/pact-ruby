require 'pact/provider/help/content'

module Pact
  module Provider
    module Help
      describe Content do
        describe "#text" do
          before do
            allow(PactDiff).to receive(:call).with(pact_source_1).and_return('diff 1')
            allow(PactDiff).to receive(:call).with(pact_source_2).and_return(nil)
          end

          let(:pact_source_1) { { some: 'json'}.to_json }
          let(:pact_source_2) { { some: 'other json'}.to_json }
          let(:pact_sources) { [pact_source_1, pact_source_2] }

          subject { Content.new(pact_sources) }

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
