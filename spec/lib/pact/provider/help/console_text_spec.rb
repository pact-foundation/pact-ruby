require 'spec_helper'
require 'pact/provider/help/console_text'
require 'fileutils'

module Pact
  module Provider
    module Help
      describe ConsoleText do

        describe ".call" do
          let(:help_path) { File.join(reports_dir, Write::HELP_FILE_NAME)}
          let(:reports_dir) { "./tmp/reports/pacts" }
          let(:color) { false }

          subject { ConsoleText.call(reports_dir, color: color) }

          context "when the help file is found" do

            let(:help_text) do
<<-EOS
# Heading
## Another heading
Text
EOS
            end

            before do
              FileUtils.mkdir_p reports_dir
              File.open(help_path, "w") { |io| io << help_text }
            end

            it "returns the help file text" do
              expect(subject).to eq help_text
            end

            context "when the reports_dir is nil" do
              subject { ConsoleText.call(nil, color: false) }

              before do
                allow(Pact.configuration).to receive(:reports_dir).and_return(reports_dir)
              end

              it "uses the default reports_dir" do
                expect(subject).to eq help_text
              end
            end

            context "with color: true" do

              let(:color) { true }

              it "colourises the headings" do
                expect(subject).to_not include("# Heading")
                expect(subject).to include("Heading")
              end
            end

            context "when the help file cannot be found" do

              before do
                FileUtils.rm_rf reports_dir
              end

              it "returns an apologetic error message" do
                expect(subject).to include("Sorry")
                expect(subject).to include("tmp/reports/pacts")
              end
            end
          end
        end
      end
    end
  end
end
