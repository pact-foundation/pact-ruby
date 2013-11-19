require 'pact/provider/pact_helper_locator'
pact_helper_path = Pact::Provider::PactHelperLocater.pact_helper_path
load pact_helper_path
puts "Using #{pact_helper_path}"
