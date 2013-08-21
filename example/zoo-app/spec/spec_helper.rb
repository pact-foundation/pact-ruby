$: << File.expand_path("../../lib", __FILE__)

require 'zoo_app/animal_service_client'

RSpec.configure do | config |
  config.color = true
  config.formatter = :documentation
end