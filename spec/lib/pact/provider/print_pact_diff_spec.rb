require 'pact/provider/print_pact_diff'

module Pact
  module Provider
    describe PrintPactDiff do

      let(:href) { 'http://pact-broker/diff' }
      let(:pact_json) do
        {
          '_links' => {
            'pb:diff-previous-distinct' => {
              'href' => href
            }
          }
        }.to_json
      end

      let(:output) { StringIO.new }
      let(:diff) { {some: 'diff'}.to_json }
      let(:diff_stream) { double('diff stream', read: diff) }

      describe ".call" do

        before do
          stub_request(:get, "http://pact-broker/diff").
            to_return(:status => 200, :body => diff, :headers => {})
        end

        subject { PrintPactDiff.(pact_json, output) }

        context "when there are no links" do
          let(:pact_json) { {}.to_json }

          it "prints nothing" do
            subject
            expect(output.string).to be_empty
          end
        end

        context "when the diff rel is not found" do
          let(:pact_json) do
            {
              '_links' => {}
              }.to_json
          end

          it "prints nothing" do
            subject
            expect(output.string).to be_empty
          end
        end

        context "when the diff rel does not have a href" do
          let(:pact_json) do
            {
              '_links' => {
                'pb:diff-previous-distinct' => {}
              }
            }.to_json
          end

          it "prints nothing" do
            subject
            expect(output.string).to be_empty
          end
        end

        context "when the diff rel changes because Beth can't make up her mind" do
          let(:pact_json) do
            {
              '_links' => {
                'distinct-diff-previous' => {
                  'href' => href
                }
              }
            }.to_json
          end

          it "prints something" do
            subject
            expect(output.string).to_not be_empty
          end
        end

        context "when the diff resource exists" do

          it "prints a message" do
            subject
            expect(output.string).to include("The following changes")
          end
          it "prints the diff" do
            subject
            expect(output.string).to include('some')
            expect(output.string).to include('diff')
          end
        end

        context "when the diff resource doesn't exist" do
          before do
            stub_request(:get, "http://pact-broker/diff").
              to_return(:status => 404)
          end

          it "prints a warning" do
            subject
            expect(output.string).to include "Tried to retrieve diff with previous pact from #{href}, but received response code 404"
          end
        end

        context "when a redirect is received" do
          before do
            stub_request(:get, "http://pact-broker/diff").
              to_return(:status => 301, :body => diff, :headers => {})

          end

          xit "follows the redirect" do
            subject
            expect(output.string).to_not include "301"
          end
        end
      end
    end
  end
end
