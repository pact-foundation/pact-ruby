# frozen_string_literal: true

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:pact).tap do |task|
  task.pattern = 'spec/pact/consumers/**/*_spec.rb'
  task.rspec_opts = '--require rails_helper --tag pact'
end

namespace :pact do
  desc 'Verifies the pact files'
  task verify: :pact
end
