$: << File.expand_path("../../lib", __FILE__)

RSpec.configure do | config |
  config.color = true
  config.formatter = :documentation
end