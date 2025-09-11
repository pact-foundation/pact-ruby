# frozen_string_literal: true

require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:pact_v2).tap do |task|
  task.pattern = "spec/pact/consumers/**/*_spec.rb"
  task.rspec_opts = "--require rails_helper_v2 --tag pact_v2"
end

namespace :pact_v2 do
  desc "Verifies the pact files"
  task verify: :pact_v2
end
