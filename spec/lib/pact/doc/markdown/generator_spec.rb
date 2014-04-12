require 'spec_helper'
require 'pact/doc/markdown/generator'

module Pact
  module Doc
    module Markdown
      describe Generator do

        subject { Generator.new './spec/pacts', './tmp/doc' }


        describe "call" do
          it "does something" do
            subject.call
          end
        end

      end
    end
  end
end