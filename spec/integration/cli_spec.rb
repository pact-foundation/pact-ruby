require 'open3'
require 'support/cli'

describe "running the pact verify CLI" do

  include Pact::Support::CLI

  describe "running a failing test with --backtrace" do
    let(:command) do
      [
        "bundle exec bin/pact verify",
        "--pact-uri spec/support/test_app_fail.json",
        "--pact-helper spec/support/pact_helper.rb",
        "--backtrace 2>&1"
      ].join(" ")
    end
    it "displays the full backtrace" do
      execute_command command, with: [/describe_interaction/]
    end
  end

  describe "running a failing test without --backtrace" do
    let(:command) do
      [
        "bundle exec bin/pact verify",
        "--pact-uri spec/support/test_app_fail.json",
        "--pact-helper spec/support/pact_helper.rb 2>&1"
      ].join(" ")
    end
    xit "does not display the full backtrace - need to fix test to work with rspec2" do
      execute_command command, without: [/describe_interaction/]
    end
  end
end
