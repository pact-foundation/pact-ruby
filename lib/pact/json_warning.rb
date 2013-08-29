require 'logger'
require 'json/add/regexp'

module Pact
  module JsonWarning
    def check_for_active_support_json
      @already_warned ||= false
      # Active support clobbers the as_json methods defined in the json/add directory of the json gem.
      # These methods are required to serialize and deserialize the Regexp and Symbol classes properly.
      # You can potentially fix this by making sure the json gem is required AFTER the active_support/json gem
      # OR if you don't use the json part of activesupport you could only require the parts of active support you really need
      # OR you can only use strings in your pacts.
      # Good luck.

      # If someone knows how to make sure the pact gem uses the json gem as_json methods when activesupport/json is used in the calling code,
      # without breaking the calling code, which may depend on activesupport/json... then please fix this.
      # Note: we can probably do this in Ruby 2.0 with refinements, but for now, we're all stuck on 1.9 :(

      unless @already_warned
        unless Regexp.new('').as_json.is_a?(Hash)
          Logger.new($stderr).warn("It appears you are using ActiveSupport json in your project. You are now in rubygems hell. Please see Pact::JsonWarning for more info.")
          @already_warned = true
        end
      end
    end
  end
end