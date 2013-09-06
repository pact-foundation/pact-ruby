require 'spec_helper'
require 'pact/provider/pact_spec_runner'

module Pact::Provider
  describe PactSpecRunner do
    describe "pact_helper_file", :fakefs => true do

      subject { PactSpecRunner.new({}).send(:pact_helper_file) }

      def make_pactfile dir
        FileUtils.mkdir_p ".#{dir}"
        FileUtils.touch ".#{dir}/pact_helper.rb"
      end

      PACT_HELPER_FILE_DIRS = [
        '/spec/blah/service-consumers',
        '/spec/consumers',
        '/spec/blah/service_consumers',
        '/spec/serviceconsumers',
        '/spec/consumer',
        '/spec',
        '/blah',
        '/blah/consumer',
        ''
      ]

      PACT_HELPER_FILE_DIRS.each do | dir |
        context "the pact_helper is stored in #{dir}" do
          it "finds the pact_helper" do
            make_pactfile dir
            expect(subject).to eq "#{Dir.pwd}#{dir}/pact_helper.rb"
          end
        end
      end

      context "when more than one pact_helper exists" do
        it "returns the one that matches the most explict search pattern" do
          make_pactfile '/spec/consumer'
          FileUtils.touch 'pact_helper.rb'
          expect(subject).to eq "#{Dir.pwd}/spec/consumer/pact_helper.rb"
        end
      end
    end
  end
end