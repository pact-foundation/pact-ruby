require 'pact/tasks/verification_task'
# Use for end to end manual debugging of issues.

BROKER_BASE_URL = 'http://localhost:9292'
#BROKER_BASE_URL = 'https://test.pact.dius.com.au'
BROKER_USERNAME = ENV['PACT_BROKER_USERNAME']
BROKER_PASSWORD = ENV['PACT_BROKER_PASSWORD']

RSpec::Core::RakeTask.new('pact:foobar:create') do | task |
  task.pattern = "spec/features/foo_bar_spec.rb"
end

task 'pact:foobar:publish' do
  # Can't require pact_broker-client because it requires pact - circular dependency
  require 'net/http'
  uri = URI("#{BROKER_BASE_URL}/pacts/provider/Bar/consumer/Foo/version/1.0.0")
  put_request = Net::HTTP::Put.new(uri.path)
  put_request['Content-Type'] = "application/json"
  put_request.body = File.read("spec/pacts/foo-bar.json")
  put_request.basic_auth(BROKER_USERNAME, BROKER_PASSWORD) if BROKER_USERNAME
  response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: BROKER_BASE_URL.start_with?('https')) do |http|
    http.request put_request
  end
  puts response.code unless response.code == '200'
end

#'./spec/pacts/foo-bar.json'
Pact::VerificationTask.new('foobar') do | pact |
  pact.uri nil, pact_helper: './spec/support/bar_pact_helper.rb'
end

Pact::VerificationTask.new('foobar:wip') do | pact |
  pact.uri './spec/pacts/foo-bar-wip.json', pact_helper: './spec/support/bar_pact_helper.rb'
  pact.wip = true
end

Pact::VerificationTask.new(:foobar_using_broker) do | pact |
  pact.uri "#{BROKER_BASE_URL}/pacts/provider/Bar/consumer/Foo/version/1.0.0", :pact_helper => './spec/support/bar_pact_helper.rb', username: BROKER_USERNAME, password: BROKER_PASSWORD
end

Pact::VerificationTask.new('foobar_using_broker:fail') do | pact |
  pact.uri "#{BROKER_BASE_URL}/pacts/provider/Bar/consumer/Foo/version/1.0.0", :pact_helper => './spec/support/bar_fail_pact_helper.rb', username: BROKER_USERNAME, password: BROKER_PASSWORD
end

task 'pact:verify:foobar' => ['pact:foobar:create']
task 'pact:verify:foobar_using_broker' => ['pact:foobar:create', 'pact:foobar:publish']
task 'pact:verify:foobar_using_broker:fail' => ['pact:foobar:create', 'pact:foobar:publish']

