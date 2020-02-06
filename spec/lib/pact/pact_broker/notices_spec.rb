require 'pact/pact_broker/notices'

module Pact
  module PactBroker
    describe Notices do

      let(:notice_hashes) do
        [
          { text: "foo", when: "before_verification" }
        ]
      end

      subject(:notices) { Notices.new(notice_hashes) }

      it "behaves like an array" do
        expect(subject.size).to eq notice_hashes.size
      end

      describe "before_verification_notices" do
        let(:notice_hashes) do
          [
            { text: "foo", when: "before_verification" },
            { text: "bar", when: "blah" },
          ]
        end

        its(:before_verification_notices_text) { is_expected.to eq [ "foo" ] }
      end

      describe "after_verification_notices_text" do
        let(:notice_hashes) do
          [
            { text: "foo", when: "after_verification:success_false_published_true" },
            { text: "bar", when: "blah" },
          ]
        end

        subject { notices.after_verification_notices_text(false, true) }

        it { is_expected.to eq [ "foo" ] }
      end

      describe "after_verification_notices" do
        let(:notice_hashes) do
          [
            { text: "meep", when: "after_verification" },
            { text: "foo", when: "after_verification:success_false_published_true" },
            { text: "bar", when: "blah" },
          ]
        end

        subject { notices.after_verification_notices(false, true) }

        it { is_expected.to eq [{ text: "meep", when: "after_verification" }, { text: "foo", when: "after_verification" }] }
      end
    end
  end
end
