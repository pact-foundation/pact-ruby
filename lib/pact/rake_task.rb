require 'rake/tasklib'


module Pact

  ##
  # To enable `rake pact`, put something like this in your Rakefile:
  #
  #     ```
  #     require 'pact/rake_task'
  #
  #     Pact::RakeTask.new do |pact|
  #       pact.file 'spec/pacts/some-pact.json',
  #         from_url: 'http://example.com/some-pact.json'
  #       pact.file 'spec/pacts/other-pact.json',
  #         from_url: 'http://example.com/other-pact.json'
  #     end
  #     ```
  class RakeTask < ::Rake::TaskLib
    attr_reader :connections

    def initialize(name = :pact)
      @connections = []

      yield self

      namespace name do
        desc "Update integration pacts from external sources"
        task :pull do
          connections.each do |conn|
            body = fetch conn[:url]
            File.open(conn[:file], 'w') {|f| f.write body }
            puts "Wrote #{conn[:url]} to #{conn[:file]}"
          end
        end
      end
      task name => "#{name}:pull" # default task for the namespace
    end

    def file(filename, options = {})
      url = options.fetch(:from_url)
      @connections << {file: filename, url: url}
    end

    private
    # written with plain Net::HTTP to avoid bringing in extra dependencies
    def fetch(url_string, redirection_limit = 5)
      raise 'Too many HTTP redirects' if redirection_limit == 0
      url = URI.parse(url_string)
      response = Net::HTTP.get_response(url)
      case response
      when Net::HTTPSuccess then
        response.body
      when Net::HTTPRedirection then
        location = response['Location']
        fetch(location, redirection_limit - 1)
      else
        response.value # raise the appropriate error
      end
    end
  end


end
