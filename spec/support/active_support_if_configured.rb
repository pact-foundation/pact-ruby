if ENV['LOAD_ACTIVE_SUPPORT']
   $stderr.puts 'LOADING ACTIVE SUPPORT!!!! Hopefully it all still works'
   require 'active_support/all'
   require 'active_support'
   require 'active_support/json'
end