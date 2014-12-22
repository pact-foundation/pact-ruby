require 'spec_helper'
require 'pact/provider/help/prompt_text'

module Pact
  module Provider
    module Help
      describe PromptText do

        describe ".call" do
          let(:reports_dir){ File.expand_path "./reports/pacts" }
          let(:color) { false }
          subject { PromptText.(reports_dir, color: color)}

          it "returns a prompt to tell the user how to get help" do
            expect(subject).to eq "For assistance debugging failures, run `bundle exec rake pact:verify:help`\n"
          end

          context "when color: true" do
            let(:color) { true }
            it "displays the message in color" do
              expect(subject).to include "\e["
            end
          end

          context "when the reports_dir is not in the standard location" do
            let(:reports_dir) { File.expand_path "reportyporty/pacts" }
            it "includes the report dir as the rake task arg so that the rake task knows where to find the help file" do
              expect(subject).to include("[reportyporty/pacts]")
            end
          end
        end

      end
    end
  end
end
