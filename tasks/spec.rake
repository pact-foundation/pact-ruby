RSpec::Core::RakeTask.new('spec') do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.rspec_opts = '--require spec_helper --require rails_helper'
end

RSpec::Core::RakeTask.new('pact:spec') do |task|
  task.pattern = 'spec/pact/providers/**/*_spec.rb'
  task.rspec_opts = ['-t pact', '--require spec_helper --require rails_helper']
end

RSpec::Core::RakeTask.new('pact:verify') do |task|
  task.pattern = 'spec/pact/consumers/*_spec.rb'
  task.rspec_opts = ['-t pact', '--require spec_helper --require rails_helper']
end

desc 'Run all spec tasks'
task 'spec:all' => ['spec', 'pact:spec', 'pact:verify']
