RSpec::Core::RakeTask.new('spec:v2') do |t|
  t.pattern = 'spec/v2/**/*_spec.rb'
  t.rspec_opts = '--require spec_helper_v2 --require rails_helper_v2'
end

RSpec::Core::RakeTask.new('pact:v2:spec') do |task|
  task.pattern = 'spec/pact/providers/**/*_spec.rb'
  task.rspec_opts = ['-t pact_v2', '--require spec_helper_v2 --require rails_helper_v2']
end

RSpec::Core::RakeTask.new('pact:v2:verify') do |task|
  task.pattern = 'spec/pact/consumers/*_spec.rb'
  task.rspec_opts = ['-t pact_v2', '--require spec_helper_v2 --require rails_helper_v2']
end

# Need to run this in separate process because left over state from
# testing the actual pact framework messes up the tests that actually
# use pact.
# RSpec::Core::RakeTask.new('spec:provider') do |task|
#   task.pattern = 'spec/service_providers/**/*_test.rb'
# end

# task :set_active_support_on do
#   ENV['LOAD_ACTIVE_SUPPORT'] = 'true'
# end

# desc 'This is to ensure that the gem still works even when active support JSON is loaded.'
# task spec_with_active_support: [:set_active_support_on] do
#   Rake::Task['pact:v2'].execute
# end


desc 'Run all v2 spec tasks'
task 'spec:v2:all' => ['spec:v2', 'pact:v2:spec', 'pact:v2:verify']