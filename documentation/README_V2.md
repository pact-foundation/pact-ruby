# Pact Ruby V2

The `pact-ruby-v1` is in maintenance mode, as there has been a transition to rust-core, which is intended to be used through FFI in non-Rust stacks.

`pact-ruby v2` implements support for the latest versions of Pact specifications:

- It's based on pact-ffi and pact-ruby-ffi
- It provides a convenient DSL, simplifying the writing of contract tests in Ruby/RSpec
- Writing contract tests with HTTP transports
- Writing contract tests with non-HTTP transports (for example, gRPC)
- Writing contract tests for async messages (Kafka, etc.)
- Verifying contract tests for HTTP/non-HTTP/async message transport
  - V4 specification supports mixed pact interactions in a single file.

## Architecture

![Pact tests architecture](./pact-v2-arch.png)

- DSL - implementation of RSpec-DSL for convenient writing of Pact tests
- Matchers - implementation of Pact matchers, which are convenient helpers used in consumer-DSL, encapsulating all the logic for serialization into Pact format
- Mock servers - mock servers that allow for correct execution of provider tests

## Usage

For each type of interaction (due to their specific features), a separate version of DSL has been implemented. However, the general principles remain the same for each type of interaction.

Place your consumer tests under

`spec/pact/provider/**`

**it's not an error: consumer tests contain `providers` subdirectory (because we're testing against different providers)**

```ruby

# Declaration of a consumer test, always include the :pact tag
# This is used in CI/CD pipelines to separate Pact tests from other RSpec tests
# Pact tests are not run as part of the general RSpec pipeline
RSpec.describe "SomePactConsumerTestForAnyTransport", :pact do
  # declaration of the type of interaction - here we determine which consumer and provider interact on which transport
  has_http_pact_between "CONSUMER-NAME", "PROVIDER-NAME"
  # or
  has_grpc_pact_between "CONSUMER-NAME", "PROVIDER-NAME"
  # or
  has_message_pact_between "CONSUMER-NAME", "PROVIDER-NAME"

  # the context for one of the interactions, for example GET /api/v2/stores
  context "with GET /api/v2/stores" do
      let(:interaction) do
        # creating a new interaction - within which we describe the contract
        new_interaction
          # if you need to save any metadata for subsequent use by the test provider,
          # for example, specify the entity ID that will need to be moved to the database in the test provider
          # we use the provider states, see more at https://docs.pact.io/getting_started/provider_states
          .given("UNIQUE PROVIDER STATE", key1: value1, key2: value2)
          # the description of the interaction, used for identification inside the package binding,
          # is optional in some cases, but it is recommended to always specify
          .upon_receiving("UNIQUE INTERACTION DESCRIPTION")
          # the description of the request using the matchers
          # the name and parameters of the method differ for different transports
          .with_request(...)
          # the description of the response using the matchers
          # the name and parameters of the method differ for different transports
          .will_respond_with(...)
          # further, there are differences for different types of transports,
          # for more information, see the relevant sections of the documentation
      end

      it "executes the pact test without errors" do | mock_server |
        interaction.execute do
          # the url of the started mock server, you should pass this into your api client in the next step
          mock_server_url = mock_server.url
          # here our client is called for the API being tested
          # in this context, the client can be: http client, grpc client, kafka consumer
          expect(make_request).to be_success
        end
      end
    end
  end

```

Common DSL Methods:

- `new_interaction` - initializes a new interaction
- `given` - allows specifying a provider state with or without parameters, for more details see <https://docs.pact.io/getting_started/provider_states>
- `upon_receiving` - allows specifying the name of the interaction

Multiple interactions can be declared within a single rspec example, in order to call the mock server

- `execute_http_pact`: Use this instead of `interaction.execute`

### HTTP consumers

Specific DSL methods:

- `with_request({method: string, path: string, headers: kv_hash, body: kv_hash})` - request definition
- `will_respond_with({status: int, headers: kv_hash, body: kv_hash})` - response definition

More at [http_client_spec.rb](../spec/pact/providers/pact-ruby-v2-test-app/http_client_spec.rb)

### gRPC consumers

Specific DSL methods:

- `with_service(PROTO_PATH, RPC_SERVICE_AND_ACTION)` - specifies the contract used, PROTO_PATH is relative from the app root
- `with_request(request_kv_hash)` - request definition
- `will_respond_with(response_kv_hash)` - response definition

More at [grpc_client_spec.rb](../spec/pact/providers/pact-ruby-v2-test-app/grpc_client_spec.rb)

### Kafka consumers

Specific DSL methods:

- `with_headers(kv_hash)` - message-headers definition; you can use matchers
- `with_metadata(kv_hash)` - message-metadata definition (special keys are `key` and `topic`, where, respectively, you can specify the matchers for the partitioning key and the topic

Next, the specifics are one of two options for describing the format:

**JSON** (to describe a message in a JSON representation):

- `with_json_contents(kv_hash)` - message format definition

**PROTO** (to describe the message in the protobuf view):

- `with_proto_class(PROTO_PATH, PROTO_MESSAGE_NAME)` - specifies the contract used, PROTO_PATH is relative to the root, PROTO_MESSAGE_NAME is the name of the message used from the proto file
- `with_proto_contents(kv_hash)` - message format definition

More at [kafka_spec.rb](../spec/pact/providers/pact-ruby-v2-test-app/kafka_spec.rb)

### Matchers

Matchers are special helper methods that allow you to define rules for matching request/response parameters at the level of the pact manifest.
The matchers are described in the [Pact specifications](https://github.com/pact-foundation/pact-specification). In this gem, the matchers are implemented as RSpec helpers.

For details of the implementation, see [matchers.rb](../lib/pact/v2/matchers.rb)

- `match_exactly(sample)` - match the exact value specified in the sample
- `match_type_of(sample)` - match the data type (integer, string, boolean) specified in the sample
- `match_include(sample)` - match a substring
- `match_any_string(sample)` - match any string, because of the peculiarities, null and empty strings will also be matched here
- `match_any_integer(sample)` - match any integer
- `match_any_decimal(sample)` - match any float/double
- `match_any_number(sample)` - match any integer/float/double
- `match_any_boolean(sample)` - match any true/false
- `match_uuid(sample)` - match any UUID (`match_regex` is used under the hood)
- `match_regex(regex, sample)` - match by regexp
- `match_datetime(format, sample)` - match any datetime
- `match_iso8601(sample)` - match datetime in ISO8601 (the matcher does not fully comply with ISO8601, matches only the most common variants, `match_regex` is used under the hood)
- `match_date(format, sample)` - match any date (rust datetime)
- `match_time(format, sample)` - match any time (rust datetime)
- `match_each(template)` - match all the elements of the array according to the specified template, you can use it for nested elements
- `match_each_regex(regex, sample)` - match all array elements by regex, used for arrays with string elements
- `match_each_key(template, key_matchers)` - match each hash key according to the specified template
- `match_each_value(template)` - match each hash value according to the specified template, can be used for nested elements
- `match_each_kv(template, key_matchers)` - match all the keys/values of Hash according to the specified template and key_matchers, can be used for nested elements

See the different uses of the matchers in [matchers_spec.rb](../spec/pact/v2/matchers_spec.rb)

### Generators

Generators are helper methods that allow you to specify dynamic values in your contract tests. These values are generated at runtime, making your contracts more flexible and robust. Below are the available generator methods:

For details of the implementation, see [matchers.rb](../lib/pact/v2/generators.rb)

- `generate_random_int(min:, max:)`  - Generates a random integer between the specified `min` and `max`.
- `generate_random_decimal(digits:)` - Generates a random decimal number with the specified number of `digits`.
- `generate_random_hexadecimal(digits:)` - Generates a random hexadecimal string with the specified number of `digits`.
- `generate_random_string(size:)` - Generates a random string of the specified `size`.
- `generate_uuid(example: nil)` - Generates a random UUID. Optionally, provide an `example` value.
- `generate_date(format: nil, example: nil)` - Generates a date string in the specified `format`. Optionally, provide an `example`.
- `generate_time(format: nil)` - Generates a time string in the specified `format`.
- `generate_datetime(format: nil)` - Generates a datetime string in the specified `format`.
- `generate_random_boolean` - Generates a random boolean value (`true` or `false`).
- `generate_from_provider_state(expression:, example:)` - Generates a value from the provider state using the given `expression` and `example` value. Allows templating of url and query paths with values only know at provider verification time.
- `generate_mock_server_url(regex: nil, example: nil)` - Generates a mock server URL. Optionally, specify a `regex` matches and/or an `example` value.

These generators can be used in your DSL definitions to provide dynamic values for requests, responses, or messages in your contract tests.

#### Generator Examples

```rb
  .with_request(
    method: :get, 
    path: generate_from_provider_state(
      expression: '/alligators/${alligator_name}',
      example: '/alligators/Mary'),
    headers: headers)

...

  body: {
    _links: {
      :'pf:publish-provider-contract' => {
        href: generate_mock_server_url(
          regex: ".*(\\/provider-contracts\\/provider\\/.*\\/publish)$",
          example: "/provider-contracts/provider/{provider}/publish"
        ),
        boolean: generate_random_boolean,
        integer: generate_random_int(min: 1, max: 100),
        decimal: generate_random_decimal(digits: 2),
        hexidecimal: generate_random_hexadecimal(digits: 8),
        string: generate_random_string(size: 10),
        uuid: generate_uuid,
        date: generate_date(format: "yyyyy.MMMMM.dd GGG"),
        time: generate_time(),
        datetime: generate_datetime(format: "%Y-%m-%dT%H:%M:%S%z")
      }
    }
  }
```

## Provider verification

Place your provider verification file under

`spec/pact/consumers/**`

**it's not an error: provider tests contain `consumers` subdirectory (because we're verifying against different consumer)**

### Provider verification options

```rb
            @provider_name = provider_name
            @log_level = opts[:log_level] || :info
            @pact_dir = opts[:pact_dir] || nil
            @provider_setup_port = opts[:provider_setup_port] || 9001
            @pact_proxy_port = opts[:provider_setup_port] || 9002
            @pact_uri = ENV.fetch("PACT_URL", nil) || opts.fetch(:pact_uri, nil)
            @publish_verification_results = ENV.fetch("PACT_PUBLISH_VERIFICATION_RESULTS", nil) == "true" || opts.fetch(:publish_verification_results, false)
            @provider_version = ENV.fetch("PACT_PROVIDER_VERSION", nil) || opts.fetch(:provider_version, nil)
            @provider_build_uri = ENV.fetch("PACT_PROVIDER_BUILD_URL", nil) || opts.fetch(:provider_build_uri, nil)
            @provider_version_branch = ENV.fetch("PACT_PROVIDER_BRANCH", nil) || opts.fetch(:provider_version_branch, nil)
            @provider_version_tags = ENV.fetch("PACT_PROVIDER_VERSION_TAGS", nil) || opts.fetch(:provider_version_tags, [])
            @consumer_version_tags = ENV.fetch("PACT_CONSUMER_VERSION_TAGS", nil) || opts.fetch(:consumer_version_tags, [])
            @consumer_version_selectors = ENV.fetch("PACT_CONSUMER_VERSION_SELECTORS", nil) || opts.fetch(:consumer_version_selectors, nil)
            @enable_pending = ENV.fetch("PACT_VERIFIER_ENABLE_PENDING", nil) == "true" || opts.fetch(:enable_pending, false)
            @include_wip_pacts_since = ENV.fetch("PACT_INCLUDE_WIP_PACTS_SINCE", nil) || opts.fetch(:include_wip_pacts_since, nil)
            @fail_if_no_pacts_found = ENV.fetch("PACT_FAIL_IF_NO_PACTS_FOUND", nil) == "true" || opts.fetch(:fail_if_no_pacts_found, true)
            @consumer_branch = ENV.fetch("PACT_CONSUMER_BRANCH", nil) || opts.fetch(:consumer_branch, nil)
            @consumer_version = ENV.fetch("PACT_CONSUMER_VERSION", nil) || opts.fetch(:consumer_version, nil)
            @consumer_name = opts[:consumer_name]
            @broker_url = ENV.fetch("PACT_BROKER_BASE_URL", nil) || opts.fetch(:broker_url, nil)
            @broker_username = ENV.fetch("PACT_BROKER_USERNAME", nil) || opts.fetch(:broker_username, nil)
            @broker_password = ENV.fetch("PACT_BROKER_PASSWORD", nil) || opts.fetch(:broker_password, nil)
            @broker_token = ENV.fetch("PACT_BROKER_TOKEN", nil) || opts.fetch(:broker_token, nil)
            @verify_only = [ENV.fetch("PACT_CONSUMER_FULL_NAME", nil)].compact || opts.fetch(:verify_only, [])
```

### Single transport providers

```rb
# frozen_string_literal: true

require "pact_broker"
require "pact_broker/app"
require "rspec/mocks"
include RSpec::Mocks::ExampleMethods
require_relative "../../service_consumers/hal_relation_proxy_app"

PactBroker.configuration.base_urls = ["http://example.org"]

pact_broker = PactBroker::App.new { |c| c.database_connection = PactBroker::TestDatabase.connection_for_test_database }
app_to_verify = HalRelationProxyApp.new(pact_broker)

require "pact"
require "pact/v2/rspec"
require_relative "../../service_consumers/shared_provider_states"
RSpec.describe "Verify consumers for Pact Broker", :pact_v2 do

  http_pact_provider "Pact Broker", opts: { 

    # rails apps should be automatically detected
    # if you need to configure your own app, you can do so here

    app: app_to_verify,
    # start rackup with a different port. Useful if you already have something
    # running on the default port *9292*
    http_port: 9393, 
    
    # Set the log level, default is :info
  
    log_level: :info,
    
    fail_if_no_pacts_found: true,

    # Pact Sources

    # 1. Local pacts from a directory

    # Default is pacts directory in the current working directory
    # pact_dir: File.expand_path('../../../../consumer/spec/internal/pacts', __dir__),
    
    # 2. Broker based pacts

    # Broker credentials
  
    # broker_username: "pact_workshop", # can be set via PACT_BROKER_USERNAME env var
    # broker_password: "pact_workshop", # can be set via PACT_BROKER_PASSWORD env var
    # broker_token: "pact_workshop", # can be set via PACT_BROKER_TOKEN env var
  
    # Remote pact via a uri, traditionally triggered via webhooks
    # when a pact that requires verification is published
  
    # 2a. Webhook triggered pacts
    # Can be a local file or a remote URL
    # Most used via webhooks
    # Can be set via PACT_URL env var
    # pact_uri: File.expand_path("../../../pacts/pact.json", __dir__),
    pact_uri: "https://raw.githubusercontent.com/YOU54F/pact_broker-client/refs/heads/feat/pact-ruby-v2/spec/pacts/Pact%20Broker%20Client%20V2-Pact%20Broker.json",
    # pact_uri: "https://raw.githubusercontent.com/YOU54F/pact_broker-client/refs/heads/feat/pact-ruby-v2/spec/pacts/pact_broker_client-pact_broker.json",
    # pact_uri: "http://localhost:9292/pacts/provider/Pact%20Broker/consumer/Pact%20Broker%20Client/version/96532124f3a53a499276c69ff2df785b8377588e",
    
    # 2b. Dynamically fetched pacts from broker

    # i. Set the broker url
    # broker_url: "http://localhost:9292", # can be set via PACT_BROKER_URL env var

    # ii. Set the consumer version selectors 
    # Consumer version selectors
    # The pact broker will return the following pacts by default, if no selectors are specified
    # For the recommended setup, you dont _actually_ need to specify these selectors in ruby
    # consumer_version_selectors: [{"deployedOrReleased" => true},{"mainBranch" => true},{"matchingBranch" => true}],
 
    # iii. Set additional dynamic selection verification options
    # additional dynamic selection verification options
    enable_pending: true,
    include_wip_pacts_since: "2021-01-01",

    # Publish verification results to the broker
    publish_verification_results: ENV["PACT_PUBLISH_VERIFICATION_RESULTS"] == "true",
    provider_version: `git rev-parse HEAD`.strip,
    provider_version_branch: `git rev-parse --abbrev-ref HEAD`.strip,
    provider_version_tags: [`git rev-parse --abbrev-ref HEAD`.strip],
    # provider_build_uri: "YOUR CI URL HERE - must be a valid url",
    
  }

  before_state_setup do
    PactBroker::TestDatabase.truncate
  end

  after_state_teardown do
    PactBroker::TestDatabase.truncate
  end

  shared_provider_states
  
end
```

### Multiple transport providers

You may have a consumer pact which consumes multiple transport protocols, if they are using pact specification v4.

In order to validate an entire pact in a single test run, you will need to configure each transport as appropriate.

```rb
# frozen_string_literal: true

require "pact/v2/rspec"

RSpec.describe "Pact::V2::Consumers::Http", :pact_v2 do
  mixed_pact_provider "pact-v2-test-app", opts: {
    http: {
      http_port: 3000,
      log_level: :info,
      pact_dir: File.expand_path('../../pacts', __dir__),
    },
    grpc: {
      grpc_port: 3009
    },
    async: {
      message_handlers: {
        # "pet message as json" => proc do |provider_state|
        #   pet_id = provider_state.dig("params", "pet_id")
        #   with_pact_producer { |client| PetJsonProducer.new(client: client).call(pet_id) }
        # end,
        # "pet message as proto" => proc do |provider_state|
        #   pet_id = provider_state.dig("params", "pet_id")
        #   with_pact_producer { |client| PetProtoProducer.new(client: client).call(pet_id) }
        # end
      }
    }
  }

  handle_message "pet message as json" do |provider_state|
    pet_id = provider_state.dig("params", "pet_id")
    with_pact_producer { |client| PetJsonProducer.new(client: client).call(pet_id) }
  end

  handle_message "pet message as proto" do |provider_state|
    pet_id = provider_state.dig("params", "pet_id")
    with_pact_producer { |client| PetProtoProducer.new(client: client).call(pet_id) }
  end
  
end

```

## Development & Test

### Setup

```shell
bundle install
```

### Run unit tests

```shell
bundle exec rake spec:v2
```

### Run pact tests

The Pact tests are not run within the general rspec pipeline, they need to be run separately, see below

#### Consumer tests

```shell
bundle exec rspec -t pact spec/pact/providers/**/*_spec.rb
or 
bundle exec rake pact:v2:spec
```

**NOTE** If you have never run it, you need to run it at least once to generate the pact files that will be used in provider tests (below)

#### Provider tests

```shell
bundle exec rspec -t pact spec/pact/consumers/*_spec.rb
or 
bundle exec rake pact:v2:spec
```

## Examples

### Migration

The following projects were designed for pact-ruby-v1 and have been migrated to pact-ruby-v2. They can serve as an example of the work required.

- pact broker client
  - v1
  - v2 <https://github.com/YOU54F/pact_broker-client/pull/1>
- pact broker
  - v1
  - v2 <https://github.com/YOU54F/pact_broker/pull/14>
- animal service
  - v1
    - In repo: [example/animal-service](../example/animal-service/)
    - Standalone: <https://github.com/safdotdev/animal-service>
  - v2
    - In repo: [example/animal-service-v2](../example/animal-service-v2/)
    - Standalone: <https://github.com/safdotdev/animal-service/pull/1>
- zoo app
  - v1
    - In repo: [example/zoo-app](../example/zoo-app/)
    - Standalone: <https://github.com/safdotdev/zoo-app>
  - v2
    - In repo: [example/zoo-app-v2](../example/zoo-app-v2/)
    - Standalone: <https://github.com/safdotdev/zoo-app/pull/1>
- message consumer/provider
  - v1
  - v2 <https://github.com/safdotdev/pact-ruby-demo/compare/main...safdotdev:pact-ruby-demo:feat/pact-ruby-v2>
- e2e http consumer/provider
  - v1
  - v2 <https://github.com/safdotdev/pact-ruby-e2e-example/pull/1>

### Demos

- http consumer
  - In repo: [http_client_spec.rb](../spec/pact/providers/pact-ruby-v2-test-app/http_client_spec.rb)
  - Standalone:
- kafka consumer
  - In repo: [kafka_spec.rb](../spec/pact/providers/pact-ruby-v2-test-app/kafka_spec.rb)
  - Standalone:
- grpc consumer
  - In repo: [grpc_client_spec.rb](../spec/pact/providers/pact-ruby-v2-test-app/grpc_client_spec.rb)
  - Standalone:
- mixed(http/kafka/grpc) provider
  - In repo:  [multi_spec.rb](../spec/pact/consumers/multi_spec.rb)
  - Standalone:
