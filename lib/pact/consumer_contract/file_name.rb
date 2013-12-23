module Pact

  #TODO move to external file for reuse
  module FileName
    def file_name consumer_name, provider_name
      "#{filenamify(consumer_name)}-#{filenamify(provider_name)}.json"
    end

    def filenamify name
      name.downcase.gsub(/\s/, '_')
    end
  end
end