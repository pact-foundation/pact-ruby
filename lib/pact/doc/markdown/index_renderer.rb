require 'erb'

module Pact
  module Doc
    module Markdown
      class IndexRenderer

        attr_reader :consumer_name
        attr_reader :docs # Hash of pact title => file_name

        def initialize consumer_name, docs
          @consumer_name = consumer_name
          @docs = docs
        end

        def self.call consumer_name, docs
          new(consumer_name, docs).call
        end

        def call
          title + "\n\n" + table_of_contents + "\n"
        end

        private

        def table_of_contents
          docs.collect do | title, file_name |
            item title, file_name
          end.join("\n")
        end

        def title
          "### Pacts for #{consumer_name}"
        end

        def item title, file_name
          "* [#{title}](#{ERB::Util.url_encode(file_name)})"
        end

      end
    end
  end
end