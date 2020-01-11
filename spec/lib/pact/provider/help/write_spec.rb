require 'pact/provider/help/write'

module Pact
  module Provider
    module Help
      describe Write do

        describe "#call" do

          let(:pact_sources) { double('pact jsons') }
          let(:reports_dir) { "./tmp/reports" }
          let(:text) { "help text" }

          before do
            FileUtils.rm_rf reports_dir
            allow_any_instance_of(Content).to receive(:text).and_return(text)
          end

          subject { Write.call(pact_sources, reports_dir) }

          let(:actual_contents) { File.read(File.join(reports_dir, Write::HELP_FILE_NAME)) }

          it "passes the pact_sources into the Content" do
            expect(Content).to receive(:new).with(pact_sources).and_return(double(text: ''))
            subject
          end

          it "writes the help content to a file" do
            subject
            expect(actual_contents).to eq(text)
          end

        end

      end
    end
  end
end
