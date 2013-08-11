require 'ostruct'


module Pact
  module Producer
    module ConfigurationDSL

      def producer &block
        @producer ||= nil
        if block_given?
          @producer = ProducerDSL.new(&block).create_producer_config
        elsif @producer
          @producer
        else
          raise "Please configure your producer. See the Producer section in the README for examples."
        end
      end

      class ProducerConfig
        attr_accessor :name

        def initialize name, &app_block
          @name = name
          @app_block = app_block
        end

        def app
          @app_block.call
        end
      end

      class ProducerDSL

        def initialize &block
          @app = nil
          @name = nil
          instance_eval(&block)
        end

        def validate
          raise "Please provide a name for the Producer" unless @name
          raise "Please configure an app for the Producer" unless @app_block
        end

        def name name
          @name = name
        end

        def app &block
          @app_block = block
        end

        def create_producer_config
          validate
          ProducerConfig.new(@name, &@app_block)
        end
      end
    end
  end
end

Pact::Configuration.send(:include, Pact::Producer::ConfigurationDSL)
