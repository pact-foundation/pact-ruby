# frozen_string_literal: true

require 'rails/railtie'

module Pact
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'pact/tasks/pact.rake'
    end
  end
end
