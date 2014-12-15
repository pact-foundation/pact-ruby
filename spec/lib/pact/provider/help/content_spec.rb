require 'pact/provider/help/content'

module Pact
  module Provider
    module Help
      describe Content do

        describe "#text" do
          it "displays the log path" do
            expect(subject.text).to include Pact.configuration.log_path
          end

          it "displays the tmp dir" do
            expect(subject.text).to include Pact.configuration.tmp_dir
          end

        end
      end
    end
  end
end
