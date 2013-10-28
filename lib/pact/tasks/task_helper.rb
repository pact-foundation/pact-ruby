module Pact
  module TaskHelper
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

    def spec_criteria defaults = {description: nil, provider_state: nil}
      criteria = {}
      [:description, :provider_state].each  do | key |
        value = ENV.fetch("PACT_#{key.to_s.upcase}", defaults[key])
        criteria[key] = Regexp.new(value) unless value.nil?
      end
      criteria.any? ? criteria : nil
    end
  end
end