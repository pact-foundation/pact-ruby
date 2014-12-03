require 'open3'

describe "running the pact verify CLI" do

  describe "running a failing test with --backtrace" do
    let(:command) do
      [
        "bundle exec bin/pact verify",
        "--pact-uri spec/support/test_app_fail.json",
        "--pact-helper spec/support/pact_helper.rb",
        "--backtrace"
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
        "--pact-helper spec/support/pact_helper.rb"
      ].join(" ")
    end
    xit "does not display the full backtrace - need to fix test to work with rspec2" do
      execute_command command, without: [/describe_interaction/]
    end
  end


  def execute_command command, options
    result = nil
    Open3.popen3(command) {|stdin, stdout, stderr, wait_thr|
      result = wait_thr.value
      ensure_patterns_present(command, options, stdout, stderr) if options[:with]
      ensure_patterns_not_present(command, options, stdout, stderr) if options[:without]
    }
    result.success?
  end

  def ensure_patterns_present command, options, stdout, stderr
    require 'term/ansicolor'
    output = stdout.read + stderr.read
    options[:with].each do | pattern |
      raise ("Could not find #{pattern.inspect} in output of #{command}" + "\n\n#{output}") unless output =~ pattern
    end
  end

  def ensure_patterns_not_present command, options, stdout, stderr
    require 'term/ansicolor'
    output = stdout.read + stderr.read
    options[:without].each do | pattern |
      raise ("Expected not to find #{pattern.inspect} in output of #{command}" + "\n\n#{output}") if output =~ pattern
    end
  end

end