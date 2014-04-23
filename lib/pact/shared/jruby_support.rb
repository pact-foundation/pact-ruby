module Pact
  module JRubySupport

    # Under jruby, JSON.pretty_generate inserts a blank new line between the opening and closing
    # brackets of an empty hash, like so:
    # {
    #   "empty": {
    #
    #   }
    # }
    # This screws up the UnixDiffFormatter, so we need to remove the blank lines.

    def fix_blank_lines_in_empty_hashes json
      json.gsub(/({\n)\n(\s*})/,'\1\2')
    end

  end
end