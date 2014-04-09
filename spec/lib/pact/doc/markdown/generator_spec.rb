require 'spec_helper'
require 'pact/doc/markdown/generator'

module Pact
  module Doc
    module Markdown
      describe Generator do

        subject { Generator.new './tmp/doc', './spec/pacts' }


        describe "call" do
          it "does something" do
            subject.call
          end
        end

      end
    end
  end
end