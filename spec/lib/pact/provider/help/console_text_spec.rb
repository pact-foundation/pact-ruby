require 'spec_helper'
require 'pact/provider/help/console_text'
require 'fileutils'

module Pact
  module Provider
    module Help
      describe ConsoleText do

        describe ".call" do
          let(:reports_dir) { "./tmp/reports/pacts" }
          let(:help_path) { File.join(reports_dir, Write::HELP_FILE_NAME)}
          let(:color) { false }
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

          subject { ConsoleText.call(reports_dir, color: color) }

          it "returns the help file text" do
            expect(subject).to eq help_text
          end

          context "with color: true" do

            let(:color) { true }

            it "colourises the headings" do
              expect(subject).to_not include("# Heading")
              expect(subject).to include("Heading")
            end
          end

        end

      end
    end
  end
end
