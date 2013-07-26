require 'ostruct'

module Pact

  class Configuration
    attr_accessor :pacts_path
  end

  def self.configuration
    @@configuration ||= default_configuration
  end

  def self.configure
    yield configuration
  end

  private

  def self.default_configuration
    c = Configuration.new
    c.pacts_path = File.expand_path('./spec/pacts')
    c
  end

end
