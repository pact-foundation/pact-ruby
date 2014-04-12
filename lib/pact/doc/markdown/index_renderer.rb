module Pact
  module Doc
    module Markdown
      class IndexRenderer

        attr_reader :consumer_name, :docs

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
          docs.collect do | name, file |
            item name, file
          end.join("\n")
        end

        def title
          "### Pacts for #{consumer_name}"
        end

        def item name, file
          "* [#{name}](#{file})"
        end

      end
    end
  end
end