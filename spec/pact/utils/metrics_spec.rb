require 'rspec'
require 'pact/utils/metrics'

describe Pact::Utils::Metrics do

  before do
    stub_request(:post, "https://www.google-analytics.com/collect").to_return(status: 200, body: "", headers: {})
    ENV['COMPUTERNAME'] = 'test'
    ENV['HOSTNAME'] = 'test'
  end

  describe ".report_metric" do
    subject { Pact::Utils::Metrics.report_metric("Event", "Category", "Action", "Value") }
    context 'when do not track is not set' do
      let(:expected_event) { {
        "v" => 1,
        "t" => "event",
        "tid" => "UA-117778936-1",
        "cid" => "098f6bcd4621d373cade4e832627b4f6",
        "an" => "Pact Ruby",
        "av" => Pact::VERSION,
        "aid" => "pact-ruby",
        "aip" => 1,
        "ds" => ENV['PACT_EXECUTING_LANGUAGE'] ? "client" : "cli",
        "cd2" => ENV['CI'] == "true" ? "CI" : "unknown",
        "cd3" => RUBY_PLATFORM,
        "cd6" => ENV['PACT_EXECUTING_LANGUAGE'] || "unknown",
        "cd7" => ENV['PACT_EXECUTING_LANGUAGE_VERSION'],
        "el" => "Event",
        "ec" => "Category",
        "ea" => "Action",
        "ev" => "Value"
      } }
      it 'sends metrics' do
        expect(Net::HTTP).to receive(:post).with(URI('https://www.google-analytics.com/collect'), URI.encode_www_form(expected_event), "Content-Type" => "application/x-www-form-urlencoded")
        subject
      end
    end
    context 'when do not track is set to true' do
      before do
        ENV['PACT_DO_NOT_TRACK'] = "true"
      end
      it 'does not send metrics' do
        expect(Net::HTTP).to_not receive(:post)
        subject
      end
    end
  end
end
