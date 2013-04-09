require 'spec_helper'

module Pact
  module Consumer

    shared_examples "a request" do
      describe "building from a hash" do

        let(:raw_request) do
          {
            'method' => 'get',
            'path' => '/mallory',
            'body' => 'hello mallory'
          }
        end

        subject { described_class.from_hash(raw_request) }

        its(:method) { should == 'get' }
        its(:path) { should == '/mallory' }
        its(:body) { should == 'hello mallory' }

        it "blows up if method is absent" do
          raw_request.delete 'method'
          expect { described_class.from_hash(raw_request) }.to raise_error
        end

        it "blows up if path is absent" do
          raw_request.delete 'path'
          expect { described_class.from_hash(raw_request) }.to raise_error
        end

        it "does not blow up if body is missing" do
          raw_request.delete 'body'
          expect { described_class.from_hash(raw_request) }.to_not raise_error
        end

      end
    end

    describe Request::Expected do
      it_behaves_like "a request"

      describe "matching to actual requests" do

        subject { Request::Expected.new(expected_method, expected_path, expected_body) }

        let(:expected_method) { 'get' }
        let(:expected_path) { '/foo' }
        let(:expected_body) { nil }

        let(:actual_request) { Request::Actual.new(actual_method, actual_path, actual_body) }

        let(:actual_method) { 'get' }
        let(:actual_path) { '/foo' }
        let(:actual_body) { nil }

        it "matches identical requests" do
          expect(subject.matches? actual_request).to be_true
        end

        context "when the methods are the same but one is symbolized" do
          let(:expected_method) { :get }
          let(:actual_method) { 'get' }

          it "matches" do
            expect(subject.matches? actual_request).to be_true
          end
        end

        context "when the methods are different" do
          let(:expected_method) { 'get' }
          let(:actual_method) { 'post' }

          it "does not match" do
            expect(subject.matches? actual_request).to be_false
          end
        end

        context "when the paths are different" do
          let(:expected_path) { '/foo' }
          let(:actual_path) { '/bar' }

          it "does not match" do
            expect(subject.matches? actual_request).to be_false
          end
        end

        context "when the paths vary only by a trailing slash" do
          let(:expected_path) { '/foo' }
          let(:actual_path) { '/foo/' }

          it "matches" do
            expect(subject.matches? actual_request).to be_true
          end
        end

        context "when the expected body is nil and the actual body is empty" do
          let(:expected_body) { nil }
          let(:actual_body) { '' }

          it "matches" do
            expect(subject.matches? actual_request).to be_true
          end
        end

        context "when the expected body is nested and the actual body is nil" do
          let(:expected_body) do
            {
              a: 'a'
            }
          end

          let(:actual_body) { nil }

          it "does not match" do
            expect(subject.matches? actual_request).to be_false
          end
        end

        context "when the bodies are different" do
          let(:expected_body) { 'foo' }
          let(:actual_body) { 'bar' }

          it "does not match" do
            expect(subject.matches? actual_request).to be_false
          end
        end

        context "when the expected body contains matching terms" do
          let(:expected_body) do
            {
              name: 'Bob',
              customer_id: Pact::Term.new({match: /CN.*/})
            }
          end

          let(:actual_body) do
            {
              name: 'Bob',
              customer_id: 'CN1234'
            }
          end

          it "matches" do
            expect(subject.matches? actual_request).to be_true
          end
        end

        context "when the expected body contains non-matching terms" do
          let(:expected_body) do
            {
              name: 'Bob',
              customer_id: Pact::Term.new({match: /foo/})
            }
          end

          let(:actual_body) do
            {
              name: 'Bob',
              customer_id: 'CN1234'
            }
          end

          it "does not match" do
            expect(subject.matches? actual_request).to be_false
          end
        end

      end

    end
  end

  describe Request::Actual do
    it_behaves_like "a request"
  end
end
