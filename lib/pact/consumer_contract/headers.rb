module Pact

  class DuplicateHeaderError < StandardError; end
  class InvalidHeaderNameTypeError < StandardError; end

  class Headers < Hash

    def initialize hash = {}
      hash.each_pair do | key, value |
        check_for_invalid key
        self[find_matching_key(key)] = value
      end
      self.freeze
    end

    def [] key
      super(find_matching_key(key))
    end

    def fetch *args, &block
      args[0] = find_matching_key(args[0]) if args.first
      super(*args, &block)
    end

    def key? key
      super(find_matching_key(key))
    end

    alias_method :has_key?, :key?
    alias_method :include?, :key?

    private

    def find_matching_key key
      key = key.to_s
      match = keys.find { |k| k.downcase == key.downcase }
      match.nil? ? key : match
    end

    def check_for_invalid key
      unless (String === key || Symbol === key)
        raise InvalidHeaderNameTypeError.new "Header name (#{key}) must be a String or a Symbol."
      end
      if key? key
        raise DuplicateHeaderError.new "Duplicate header found (#{find_matching_key(key)} and #{key}. Please use a comma separated single value when multiple headers with the same name are required."
      end
    end

  end

end
