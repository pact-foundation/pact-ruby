RSpec::Core::RakeTask.new(:spec)

# Need to run this in separate process because left over state from
# testing the actual pact framework messes up the tests that actually
# use pact.
RSpec::Core::RakeTask.new('spec:provider') do | task |
  task.pattern = "spec/service_providers/**/*_test.rb"
end
