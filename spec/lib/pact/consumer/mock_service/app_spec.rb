require 'spec_helper'
require 'rack/test'
require 'tempfile'

module Pact
  module Consumer

    describe MockService do

      include Rack::Test::Methods

      def app
        MockService.new(log_file: temp_file)
      end

      let(:temp_file) { Tempfile.new('log') }

      after do
        temp_file.close
        temp_file.unlink
      end

      context "when a StandardError is encountered" do
        let(:response) { JSON.parse(last_response.body)}
        let(:interaction_replay) { double(InteractionReplay, :match? => true)}

        before do
          InteractionReplay.stub(:new).and_return(interaction_replay)
          interaction_replay.stub(:respond).and_raise("an error")
        end

        subject { get "/" }

        it "returns a json error" do
          subject
          expect(last_response.content_type).to eq 'application/json'
        end

        it "includes the error message" do
          subject
          expect(response['message']).to eq "an error"
        end

        it "includes the backtrace" do
          subject
          expect(response['backtrace']).to be_instance_of Array
        end
      end

    end
  end
end
