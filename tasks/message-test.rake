require 'pact/tasks'

Pact::VerificationTask.new(:message) do | pact |
  pact.uri 'spec/pacts/foo-bar-message.json', pact_helper: 'spec/support/message_spec_helper.rb'
end
