module PactTaskHelper
  def failure_message
    redify(
      "\n* * * * * * * * * * * * * * * * * * *\n" +
      "Provider did not honour pact file.\nSee\n * #{Pact.configuration.log_path}\n * #{Pact.configuration.tmp_dir}\nfor logs and pact files." +
      "\n* * * * * * * * * * * * * * * * * * *\n\n"
    )
  end

  def redify string
    "\e[31m#{string}\e[m"
  end

  def handle_verification_failure
    exit_status = yield
    if exit_status != 0
      $stderr.puts failure_message
      fail
    end
  end
end