# frozen_string_literal: true

require "rails/railtie"

module Pact
  module V2
    class Railtie < Rails::Railtie
      rake_tasks do
        load "pact/v2/tasks/pact.rake"
      end
    end
  end
end
