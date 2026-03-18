# frozen_string_literal: true

require 'ffi'
require 'pact/ffi/verifier'

module Pact
  module Native
    module BlockingVerifier
      extend FFI::Library
      ffi_lib DetectOS.get_bin_path

      attach_function :execute, :pactffi_verifier_execute, %i[pointer], :int32, blocking: true
    end
  end
end
