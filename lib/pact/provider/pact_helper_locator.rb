module Pact
  module Provider
    module PactHelperLocater
      PACT_HELPER_FILE_PATTERNS = [
        "spec/**/*service*consumer*/pact_helper.rb",
        "spec/**/*consumer*/pact_helper.rb",
        "spec/**/pact_helper.rb",
        "test/**/*service*consumer*/pact_helper.rb",
        "test/**/*consumer*/pact_helper.rb",
        "test/**/pact_helper.rb",
        "**/pact_helper.rb"
      ]

      NO_PACT_HELPER_FOUND_MSG = "Please create a pact_helper.rb file that can be found using one of the following patterns: #{PACT_HELPER_FILE_PATTERNS.join(", ")}"

      def self.pact_helper_path
        pact_helper_search_results = []
        PACT_HELPER_FILE_PATTERNS.find { | pattern | (pact_helper_search_results.concat(Dir.glob(pattern))).any? }
        raise NO_PACT_HELPER_FOUND_MSG if pact_helper_search_results.empty?
        File.join(Dir.pwd, pact_helper_search_results[0])
      end
    end
  end
end
