require "pact/utils/metrics"

describe Pact::Utils::Metrics do
  describe ".report_metric" do
    before do
      ENV["COMPUTERNAME"] = "test"
      ENV["HOSTNAME"] = "test"
      stub_request(:post, "https://www.google-analytics.com/collect").to_return(status: 200, body: "", headers: {})
      stub_const("RUBY_PLATFORM", "x86_64-darwin20")
      allow(Pact::Utils::Metrics).to receive(:in_thread)  { |&block| block.call }
      allow(Pact.configuration).to receive(:output_stream).and_return(output_stream)
    end

    let(:output_stream) { double("stream").as_null_object }

    subject { Pact::Utils::Metrics.report_metric("Event", "Category", "Action", "Value") }

    context "when do not track is not set" do
      let(:expected_event) { {
        "v" => 1,
        "t" => "event",
        "tid" => "UA-117778936-1",
        "cid" => "098f6bcd4621d373cade4e832627b4f6",
        "an" => "Pact Ruby",
        "av" => Pact::VERSION,
        "aid" => "pact-ruby",
        "aip" => 1,
        "ds" => ENV["PACT_EXECUTING_LANGUAGE"] ? "client" : "cli",
        "cd2" => ENV["CI"] == "true" ? "CI" : "unknown",
        "cd3" => RUBY_PLATFORM,
        "cd6" => ENV["PACT_EXECUTING_LANGUAGE"] || "unknown",
        "cd7" => ENV["PACT_EXECUTING_LANGUAGE_VERSION"],
        "el" => "Event",
        "ec" => "Category",
        "ea" => "Action",
        "ev" => "Value"
      } }

      it "sends metrics" do
        subject

        expect(WebMock).to have_requested(:post, "https://www.google-analytics.com/collect").
          with(body: Rack::Utils.build_query(expected_event))
      end
    end

    context "when do not track is set to true" do
      before do
        ENV["PACT_DO_NOT_TRACK"] = "true"
      end

      it "does not send metrics" do
        subject
        expect(WebMock).to_not have_requested(:post, "https://www.google-analytics.com/collect")
      end
    end
  end
end
