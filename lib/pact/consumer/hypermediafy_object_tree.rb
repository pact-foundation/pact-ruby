module Pact

  class HypermediafyObjectTree

    def self.call hash, host_alias, mock_service_host
      new(host_alias, mock_service_host).call(hash)
    end

    def initialize host_alias, mock_service_host
      @host_alias = host_alias
      @mock_service_host = mock_service_host
    end

    def call thing
      case thing
      when Array then copy_array thing
      when Hash then copy_hash thing
      when String then copy_string thing
      else
        thing
      end
    end

    def copy_array array
      array.collect{ | thing | call thing }
    end

    def copy_hash hash
      hash.each_with_object({}) do | pair, new_hash |
        new_hash[pair.first] = call pair.last
      end
    end

    def copy_string string
      if string.include? @host_alias
        pact_term_for string
      else
        string
      end
    end

    def pact_term_for url
      url_part = Regexp.escape(url).gsub(Regexp.escape(@host_alias), "[^\/]+")
      matcher = Regexp.new(/^#{url_part}$/)
      Pact::Term.new(
        generate: url.gsub(@host_alias, @mock_service_host),
        matcher: matcher
        )
    end

  end

end