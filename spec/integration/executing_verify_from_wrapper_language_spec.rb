RSpec.describe "executing pact verify" do
  let(:command) { "bundle exec rake pact:verify:test_app:fail > /dev/null" }
  let(:reports_dir) { 'tmp/spec_reports' } # The config for this is in spec/support/pact_helper.rb

  before do
    FileUtils.rm_rf reports_dir
  end

  after do
    FileUtils.rm_rf reports_dir
  end

  context "from ruby" do
    it "creates a reports dir" do
      system({}, command)
      expect(File.exist?(reports_dir)).to be true
    end
  end

  context "with a wrapper language" do
    it "does not create a reports dir" do
      system({'PACT_EXECUTING_LANGUAGE' => 'foo'}, command)

      expect(File.exist?(reports_dir)).to be false
    end
  end
end
