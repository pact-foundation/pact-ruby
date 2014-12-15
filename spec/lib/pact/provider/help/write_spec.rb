require 'pact/provider/help/write'

module Pact
  module Provider
    module Help
      describe Write do

        describe "#call" do

          let(:report_dir) { "./tmp/reports" }
          let(:text) { "help text" }

          before do
            FileUtils.rm_rf report_dir
            allow_any_instance_of(Content).to receive(:text).and_return(text)
          end

          subject { Write.call(report_dir) }

          let(:actual_contents) { File.read(File.join(report_dir, "help.txt")) }

          it "writes the help content to a file" do
            subject
            expect(actual_contents).to eq(text)
          end

        end

      end
    end
  end
end
