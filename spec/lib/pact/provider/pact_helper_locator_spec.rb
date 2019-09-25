require 'spec_helper'
require 'pact/provider/pact_helper_locator'

module Pact::Provider

  describe PactHelperLocater do
    describe "pact_helper_path", :fakefs => true, skip_jruby: true do

      subject { PactHelperLocater.pact_helper_path }

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
        '/test/blah/service-consumers',
        '/test/consumers',
        '/test/blah/service_consumers',
        '/test/serviceconsumers',
        '/test/consumer',
        '/test',
        '/blah',
        '/blah/consumer',
        ''
      ]

      PACT_HELPER_FILE_DIRS.each do |dir|
        context "the pact_helper is stored in #{dir}" do
          it "finds the pact_helper" do
            make_pactfile dir
            expect(subject).to eq File.join(Dir.pwd, dir, 'pact_helper.rb')
          end
        end
      end

      context "when more than one pact_helper exists" do
        it "returns the one that matches the most explict search pattern" do
          make_pactfile '/spec/consumer'
          FileUtils.touch 'pact_helper.rb'
          expect(subject).to eq File.join(Dir.pwd, '/spec/consumer/pact_helper.rb')
        end
      end

      context "when a file exists ending in pact_helper.rb" do
        it "is not identifed as a pact helper" do
          FileUtils.mkdir_p './spec'
          FileUtils.touch './spec/not_pact_helper.rb'
          expect { subject }.to raise_error /Please create a pact_helper.rb file/
        end
      end
    end
  end
end