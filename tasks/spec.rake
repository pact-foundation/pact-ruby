RSpec::Core::RakeTask.new(:spec)

# Need to run this in separate process because left over state from
# testing the actual pact framework messes up the tests that actually
# use pact.
RSpec::Core::RakeTask.new('spec:provider') do | task |
  task.pattern = "spec/service_providers/**/*_test.rb"
end

task :set_active_support_on do
  ENV["LOAD_ACTIVE_SUPPORT"] = 'true'
end

desc "This is to ensure that the gem still works even when active support JSON is loaded."
task :spec_with_active_support => [:set_active_support_on] do
  Rake::Task['spec'].execute
end
