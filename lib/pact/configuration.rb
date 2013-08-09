require 'ostruct'
require 'logger'

module Pact

  class Configuration
    attr_accessor :pact_dir
    attr_accessor :log_dir
    attr_accessor :logger
  end

  def self.configuration
    @@configuration ||= default_configuration
  end

  def self.configure
    yield configuration
  end

  def self.clear_configuration
    @@configuration = default_configuration
  end

  private

  def self.default_configuration
    c = Configuration.new
    c.pact_dir = File.expand_path('./spec/pacts')
    c.log_dir = default_log_dir
    c.logger = default_logger
    c
  end

  def self.default_log_dir
    File.expand_path("./log")
  end

  def self.default_logger
    FileUtils::mkdir_p default_log_dir
    logger = Logger.new(default_log_dir + "/pact_gem.log")
    logger.level = Logger::INFO
    logger
  end

end