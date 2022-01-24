require 'securerandom'
require 'digest'
require 'socket'
require 'pact/version'

module Pact
  module Utils
    class Metrics

      def self.report_metric(event, category, action, value = 1)

        if track_events?
          Pact.configuration.output_stream.puts "WARN: Please note: we are tracking events anonymously to gather important usage statistics like Pact-Ruby version
            and operating system. To disable tracking, set the 'pact_do_not_track' environment
            variable to 'true'."

          event = {
            "v" => 1,
            "t" => "event",
            "tid" => "UA-117778936-1",
            "cid" => calculate_cid,
            "an" => "Pact Ruby",
            "av" => Pact::VERSION,
            "aid" => "pact-ruby",
            "aip" => 1,
            "ds" => ENV["CI"] || "unknown",
            "cd2" => ENV['PACT_EXECUTING_LANGUAGE'] ? "client" : "unknown",
            "cd3" => RUBY_PLATFORM,
            "cd6" => ENV['PACT_EXECUTING_LANGUAGE'] || "unknown",
            "cd7" => RUBY_VERSION,
            "el" => event,
            "ec" => category,
            "ea" => action,
            "ev" => value
          }

          Net::HTTP.post URI('https://www.google-analytics.com/collect'),
                         URI.encode_www_form(event),
                         "Content-Type" => "application/x-www-form-urlencoded"
        end
      end

      private

      def self.track_events?
        require 'pry'; pry(binding)
        if ENV['PACT_DO_NOT_TRACK'].nil?
          true
        else
          ENV['PACT_DO_NOT_TRACK'] == 'true' ? false : true
        end
      end

      def self.calculate_cid
        if RUBY_PLATFORM.include? "windows"
          hostname = ENV['COMPUTERNAME']
        else
          hostname = ENV['HOSTNAME']
        end
        if !hostname
          hostname = Socket.gethostname
        end
        Digest::MD5.hexdigest hostname || SecureRandom.urlsafe_base64(5)
      end
    end
  end
end
