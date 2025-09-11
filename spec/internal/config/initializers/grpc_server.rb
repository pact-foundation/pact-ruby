# frozen_string_literal: true

::Gruf.interceptors.clear

::Gruf.configure do |c|
  c.server_binding_url = "0.0.0.0:3009"
  c.logger = Rails.logger
end

puts "Loading gRPC service files from #{Rails.root}"
required_files = []
required_files += Rails.root.glob("pkg/server/**/*_services_pb.rb").sort
required_files += Rails.root.glob("app/rpc/**/*.rb").sort
puts "Requiring files:"
required_files.each do |file|
  require file
  puts "Required: #{file}"
end
