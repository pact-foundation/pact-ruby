require 'open3'
require 'support/cli'
require 'fileutils'

describe "running the pact docs CLI" do

  include Pact::Support::CLI

  before do
    FileUtils.rm_rf "tmp/docs"
  end

  let(:command) { "bundle exec bin/pact docs --pact-dir spec/support/docs --doc-dir tmp/docs" }

  it "writes some docs" do
    execute_command command
    expect(Dir.glob("tmp/docs/**/*").size).to_not eq 0
  end
end
