# Pact

Define a pact between service consumers and providers, enabling "consumer driven contract" testing.

Pact provides an RSpec DSL for service consumers to define the HTTP requests they will make to a service provider and the HTTP responses they expect back. These expectations are used in the consumers specs to provide a mock service provider. The interactions are recorded, and played back in the service provider specs to ensure the service provider actually does provide the response the consumer expects.

This allows testing of both sides of an integration point using fast unit tests.

This gem is inspired by the concept of "Consumer driven contracts". See http://martinfowler.com/articles/consumerDrivenContracts.html for more information.

Travis CI Status: [![travis-ci.org Build Status](https://travis-ci.org/realestate-com-au/pact.png)](https://travis-ci.org/realestate-com-au/pact)

## Features
* A service is mocked using an actual process running on a specified port, so javascript clients can be tested as easily as backend clients.
* "Provider states" (similar to fixtures) allow the same request to be made with a different expected response.
* Consumers specify only the fields they are interested in, allowing a provider to return more fields without breaking the pact. This allows a provider to have a different pact with a different consumer, and know which fields each cares about in a given response.
* Expected interactions are verified to have actually occurred in the consumer specs.
* The mocked responses are verified to be valid by replaying the interactions against the provider codebase.
* Rake verification tasks allow a pacts at one or more URIs to be checked against a given service provider codebase.
* Different versions of a consumer/provider pairs can be easily tested against each other, allowing confidence when deploying new versions of each (see the pact_broker and pact_broker-client gems).

## How does it work?

1. In the specs for the provider facing code in the consumer project, expectations are set up on a mock service provider.
1. When the specs are run, the requests, and their expected responses, are written to a "pact" file.
1. The requests in the pact file are later replayed against the provider, and the actual responses are checked to make sure they match the expected responses.

## Why is developing and testing with pacts better than using integration tests?

* Faster execution.
* No need to manage starting and stopping multiple processes.
* Reliable responses from mock service provider reduce likelihood of flakey tests.
* Only one component is being tested at a time, making the causes of test failures easier to identify.
* Design of service provider is improved by considering first how the data is actually going to be used, rather than how it is most easily retrieved and serialised.

## Contact

* Twitter: [@pact_up](https://twitter.com/pact_up)
* Google users group: https://groups.google.com/forum/#!forum/pact-support 

## Installation

Put it in your Gemfile. You know how.

## Usage

### Service Consumer project

#### 1. Start with you model

Imagine a model class that looks something like this. The attributes for a SomethingModel live on a remote server, and will need to be retrieved by an HTTP call.

```ruby
class SomethingModel
  attr_reader :name

  def initialize name
    @name = name
  end

  def == other
    other.is_a?(SomethingModel) && other.name == name
  end
end
```

#### 2. Create a skeleton client class

Imagine a service provider client class that looks something like this.

```ruby

class MyServiceProviderClient
  include HTTParty
  base_uri 'http://my-service'

  def get_something
    # Yet to be implemented because we're doing Test First Development...
  end
end

```
#### 3. Configure the mock server

The following code will create a mock service on localhost:1234 which will respond to your application's queries over HTTP as if it were the real "My Service Provider" app. It also creats a mock service provider object which you will use to set up your expectations. The method name to access the mock service provider will be what ever name you give as the service argument - in this case "my_service_provider"


```ruby
# In /spec/service_providers/pact_helper.rb

require 'pact/consumer/rspec'

Pact.service_consumer "My Service Consumer" do
  has_pact_with "My Service Provider" do
    mock_service :my_service_provider do
      port 1234
    end
  end
end
```

#### 4. Write a failing spec for the client

```ruby
# In /spec/service_providers/my_service_provider_client_spec.rb

# Use the :pact => true describe metadata to include all the pact generation functionality in your spec.
describe MyServiceProviderClient, :pact => true do

  before do
    # Configure your client to point to the stub service on localhost using the port you have specified
    MyServiceProviderClient.base_uri 'localhost:1234'
  end

  subject { MyServiceProviderClient.new }

  describe "get_something" do
    before do
      my_service_provider.
        .given("something exists")
        .upon_receiving("a request for something")
        .with( method: :get, path: '/something' )
        .will_respond_with(
          status: 200,
          headers: { 'Content-Type' => 'application/json' },
          body: {name: 'A small something'}
        )
    end

    it "returns a Something" do
      expect(subject.get_something).to eq(SomethingModel.new('A small something'))
    end

  end

end

```

#### 5. Run the specs

Running the consumer spec will generate a pact file in the configured pact dir (spec/pacts by default).
Logs will be output to the configured log dir that can be useful when diagnosing problems.

Of course, the above specs will fail because the client method is not implemented, so next, implement your client methods.

#### 6. Implement the client methods

```ruby

class MyServiceProviderClient
  include HTTParty
  base_uri 'http://my-service'

  def get_something
    name = JSON.parse(self.class.get("/something").body)['name']
    SomethingModel.new(name)
  end
end

```

#### 7. Run the specs again.

Green! You now have a pact file that can be used to verify your expectations in the provider project.
Now, rinse and repeat for ALL the likely status codes that may be returned (recommend 400, 404, 500 and 401/403 if there is authorisation.)

### Service Provider project

#### 1. Create the skeleton API classes

Create your API class using the framework of your choice (e.g. Sinatra, Grape) - leave the methods unimplemented, we're doing Test First Develoment, remember?

#### 2. Tell your provider that it needs to honour the pact file you made earlier

Create a `pact_helper.rb` in your service provider project. The file must be called pact_helper.rb, however there is some flexibility in where it can be stored. The recommended place is `specs/service_consumers/pact_helper.rb`.

```ruby
require 'pact/provider/rspec'
# If you wish to use the same spec_helper file as your unit tests, require it here.
# Otherwise, you can set up a separate RSpec configuration in this file just for pact:verify.
require './spec_helper'

Pact.service_provider "My Service Provider" do

  app { MyApp.new } # Optional, loads app from config.ru by default

  honours_pact_with 'My Service Consumer' do

    # This example points to a local file, however, on a real project with a continuous
    # integration box, you would publish your pacts as artifacts,
    # and point the pact_uri to the pact published by the last successful build.

    pact_uri '../path-to-your-consumer-project/specs/pacts/my_consumer-my_provider.json'
  end
end

```
Require "pact/tasks" in your Rakefile. If the pact gem is in the test/development section of your Gemfile, you may want to put an env check around this so it doesn't load the pact tasks in prod.

```ruby
# In Rakefile

require 'pact/tasks'
```

#### 3. Run your failing specs

    $ rake pact:verify

Congratulations! You now have a failing spec to develop against.

#### 4. Implement your service provider

At this stage, you'll probably want to be able to run your specs one at a time while you implement. Define the environment variables PACT_DESCRIPTION and/or PACT_PROVIDER_STATE as so:

    $ PACT_DESCRIPTION="a request for something" PACT_PROVIDER_STATE="something exists" rake pact:verify

#### 5. Keep going til you're green

Yay! Your provider now honours the pact it has with your consumer. You can now have confidence that your consumer and provider will play nicely together.

### Using provider states

Provider states allow different fixtures to be loaded on the provider to allow you to test the same request with different expected responses.

For example, some code that creates the pact in a consumer project might look like this:

```ruby
my_service.
   given("a thing exists").
     upon_receiving("a request for a thing").
        with(method: 'get', path: '/thing').
          will_respond_with(status: 200, :body => {thing: "yay!"} )

...

my_service.
  given("a thing does not exist").
   upon_receiving("a request for a thing").
      with(method: 'get', path: '/thing').
        will_respond_with(status: 404)

        ...

my_service.
  given("an error occurs while retrieving a thing").
   upon_receiving("a request for a thing").
      with(method: 'get', path: '/thing').
        will_respond_with(status: 500, :body => {message: "An error occurred"}, :headers => { 'Content-Type' => 'application/json'} )
```



To define service provider states that create the right data for "a thing exists" and "a thing does not exist", write the following in the service provider project. (The consumer name here must match the name of the consumer configured in your consumer project for it to correctly find these provider states.)


```ruby
# In /spec/service_consumers/provider_states_for_my_service_consumer.rb

Pact.provider_states_for 'My Service Consumer' do
  provider_state "a thing exists" do
    set_up do
      # Create a thing here using your factory of choice
    end

    tear_down do
      # Any tear down steps to clean up your code (or use RSpec.after(:each))
    end
  end

  provider_state "a thing does not exist" do
    no_op # If there's nothing to do because the state name is more for documentation purposes, you can use no_op to imply this.
  end

  provider_state "an error occurs while retrieving a thing" do
    set_up do
      ThingRepository.stub(:find).and_raise("An error occurred!")
    end
  end
end

```

```ruby
# In /spec/service_consumers/pact_helper.rb

require_relative 'provider_states_for_my_service_consumer.rb'
```

To define code that should run before/after each interaction, regardless of whether a provider state is specified or not:

```ruby

  Pact.provider_states_for 'My Service Consumer' do

    set_up do
      # eg. create API user, start database cleaner transaction
    end

    tear_down do
      # eg. clean database
    end
  end

```

Or for global set up/tear down for all consumers:

```ruby
Pact.set_up do
  # eg. start database cleaner transaction
  # Avoid using the global set up for creating data as it will make your tests brittle.
  # You don't want changes to one consumer pact to affect another one.
end

Pact.tear_down do
  # eg. clean database
end
```

### Verifying pacts

You can verify a pact at an arbitrary local or remote URL

    $ rake pact:verify:at[../path-to-your-consumer-project/specs/pacts/my_consumer-my_provider.json]
    $ rake pact:verify:at[http://build-box/MyConsumerBuild/latestSuccessful/artifacts/my_consumer-my_provider.json]

To make a shortcut task for pact at an arbitrary URL, add the following to your Rakefile. The pact.uri may be a local file system path or a remote URL.

```ruby
# In Rakefile or /tasks/pact.rake

# This creates a rake task that can be executed by running
# $ rake pact:verify:dev

Pact::VerificationTask.new(:dev) do | pact |
  pact.uri '../path-to-your-consumer-project/specs/pacts/my_consumer-my_provider.json'
end
```

### Configuration

```ruby
Pact.configure do | config |
  config.pact_dir = "???" # Optional, default is ./spec/pacts
  config.log_dir = "???" # Optional, default is ./log
  config.logger = "??" # Optional, defaults to a file logger to the configured log_dir.
  config.logger.level = Logger::DEBUG #By default this is INFO, bump this up to debug for more detailed logs
  config.pactfile_write_mode = :ovewrite / :update / :smart # Optional. The default pactfile_write_mode is :overwrite. See notes in Advanced section for further information.
end
```

## Pact best practices

### In your consumer project

#### Publish your pacts as artifacts on your CI machine

This makes the pact available via URL, which your provider build can then use when it runs pact:verify.

#### Ensure all calls to the provider go through your provider client class

Do not hand create any HTTP requests in your consumer app or specs. Testing through your provider client class gives you the assurance that your consumer app will be creating exactly the HTTP requests that you think it should.

#### Use factories to create your expected models

Sure, you've checked that your client deserialises the HTTP response into the object you expect, but then you need to make sure in your other tests where you stub your client that you're stubbing it with a valid object. The best way to do this is to use factories for all your tests.

### In your provider project

#### Use the pact artifact published by your consumer's CI build to verify the provider

Configure the pact_uri in the Pact.service_provider block with the pact artifact URL of your last successful build. This way you're only verifying green builds. No point verifying a broken one.
(Watch this space - pact-broker coming soon, so we don't have to use messy build box artifact URLs)

#### Add pact:verify to your default rake task

It should run with all your other tests. If an integration is broken, you want to know about it *before* you check in.

#### Stub calls to downstream systems

Consider making a separate pact with the downstream system and using shared fixtures.

#### Consider carefully whether to use the real database or stub calls

You may choose not stub your database calls for pact:verify. This can be a good time for you to test your database integration if you have a simple application, however, for a complex one, you might want to carefully choose a point at which to stub calls.

## Gotchas

* Be aware when using the app from the config.ru file is used (the default option) that the Rack::Builder.parse_file seems to require files even if they have already been required, so make sure your boot files are idempotent.

## Advanced

### Filtering the pact:verify specs

To execute a subset of the specs when running any of the pact verification tasks, define the environment variables PACT_DESCRIPTION and/or PACT_PROVIDER_STATE.

    $ PACT_DESCRIPTION="a request for something" PACT_PROVIDER_STATE="something exists" rake pact:verify

See [Frequently Asked Questions](https://github.com/realestate-com-au/pact/blob/master/documentation/faq.md) and [Rarely Asked Questions](https://github.com/realestate-com-au/pact/blob/master/documentation/raq.md) and [Terminology](https://github.com/realestate-com-au/pact/blob/master/documentation/terminology.md) for more information.


## Related Gems

[Pact Provider Proxy](https://github.com/bethesque/pact-provider-proxy) - Verify a pact against a running server, allowing you to use pacts with a provider of any language.

[Pact Broker](https://github.com/bethesque/pact_broker) - A pact repository. Provides endpoints to access published pacts, meaning you don't need to use messy CI URLs in your codebase. Enables cross testing of prod/head versions of your consumer and provider, allowing you to determine whether the head version of one is compatible with the production version of the other. Helps you to answer that ever so important question, "can I deploy without breaking all the things?"

[Pact Broker Client](https://github.com/bethesque/pact_broker-client) - Contains rake tasks for publishing pacts to the pact_broker.

[Shokkenki](https://github.com/brentsnook/shokkenki) - Another Consumer Driven Contract gem written by one of Pact's original authors, Brent Snook. Shokkenki allows matchers to be composed using jsonpath expressions and allows auto-generation of mock response values based on regular expressions.

## TODO

Short term:
- FIX EXAMPLE!!!
- Support hash of query params

Long term:
- Provide more flexible matching (eg the keys should match, and the classes of the values should match, but the values of each key do not need to be equal). This is to make the pact verification less brittle.
- Add XML support
- Improve display of interaction diffs
- Decouple Rspec from Pact and make rspec-pact gem for easy integration

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
