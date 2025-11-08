# frozen_string_literal: true

require 'pact/ffi/logger'

module Pact
  module Native
    module Logger
      LOG_LEVELS = {
        off: PactFfi::FfiLogLevelFilter['LOG_LEVEL_OFF'],
        error: PactFfi::FfiLogLevelFilter['LOG_LEVEL_ERROR'],
        warn: PactFfi::FfiLogLevelFilter['LOG_LEVEL_WARN'],
        info: PactFfi::FfiLogLevelFilter['LOG_LEVEL_INFO'],
        debug: PactFfi::FfiLogLevelFilter['LOG_LEVEL_DEBUG'],
        trace: PactFfi::FfiLogLevelFilter['LOG_LEVEL_TRACE']
      }.freeze

      def self.log_to_stdout(log_level)
        raise 'invalid log level for PactFfi::FfiLogLevelFilter' unless LOG_LEVELS.key?(log_level)

        PactFfi::Logger.log_to_stdout(LOG_LEVELS[log_level]) unless log_level == :off
      end
    end
  end
end
