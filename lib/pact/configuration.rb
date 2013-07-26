require 'ostruct'

module Pact

  class Configuration
    attr_accessor :pact_dir
    attr_accessor :log_dir
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
    c.pact_dir = File.expand_path('./spec/pacts')
    c.log_dir = File.expand_path("./log")
    c
  end

end
