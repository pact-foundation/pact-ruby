# frozen_string_literal: true

VCR.configure do |c|
  c.cassette_library_dir = "spec/fixtures/vcr"
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.ignore_hosts "127.0.0.1", "localhost"
  c.default_cassette_options = {
    record: :once,
    match_requests_on: %i[method uri body],
    decode_compressed_response: true
  }
end
