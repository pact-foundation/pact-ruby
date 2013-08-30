# require 'ostruct'


# module Pact
#   module Provider
#     module ConfigurationDSL

#       def provider &block
#         @provider ||= nil
#         if block_given?
#           @provider = ProviderDSL.new(&block).create_provider_config
#         elsif @provider
#           @provider
#         else
#           raise "Please configure your provider. See the Provider section in the README for examples."
#         end
#       end

#       class ProviderConfig
#         attr_accessor :name

#         def initialize name, &app_block
#           @name = name
#           @app_block = app_block
#         end

#         def app
#           @app_block.call
#         end
#       end

#       class ProviderDSL

#         def initialize &block
#           @app = nil
#           @name = nil
#           instance_eval(&block)
#         end

#         def validate
#           raise "Please provide a name for the Provider" unless @name
#           raise "Please configure an app for the Provider" unless @app_block
#         end

#         def name name
#           @name = name
#         end

#         def app &block
#           @app_block = block
#         end

#         def create_provider_config
#           validate
#           ProviderConfig.new(@name, &@app_block)
#         end
#       end
#     end
#   end
# end

# Pact::Configuration.send(:include, Pact::Provider::ConfigurationDSL)
