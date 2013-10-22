# Pact

Define a pact between service consumers and providers.


Pact provides an RSpec DSL for service consumers to define the request they will make to a service service provider and the response they expect back. This expectation is used in the consumers specs to provide a mock service provider, and is also played back in the service provider specs to ensure the service provider actually does provide the response the consumer expects.

This allows you to test both sides of an integration point using fast unit tests.

This gem is inspired by the concept of "Consumer driven contracts". See http://martinfowler.com/articles/consumerDrivenContracts.html for more information.

## Features
* A services is mocked using an actual process running on a specified port, so javascript clients can be tested as easily as backend clients.
* "Provider states" (similar to fixtures) allow the same request to be made with a different expected response.
* Consumers specify only the fields they are interested in, allowing a provider to return more fields without breaking the pact. This allows a provider to have a different pact with a different consumer, and know which fields each cares about in a given response.
* Expected interactions are verified to have actually occurred.
* A rake verification task allows a pact at any URI to be checked against a given service provider codebase.
* Different versions of a consumer/provider pair can be easily tested against each other, allowing confidence when deploying new versions of each.

## Installation

Put it in your Gemfile. You know how.

## Usage

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

### Service Consumer project

#### Create a Consumer Driven Contract (pact file) using the spec for your client class

```ruby

# Imagine a service provider client class that looks something like this

class MyServiceProviderClient
  include HTTParty
  base_uri 'http://my-service'

  def get_text_from_something
    JSON.parse(self.class.get("/something").body)['text']
  end
end

# The following code creates a service on localhost:1234 which will respond to your application's queries
# over HTTP as if it were the real "My Service Provider" app. It also creats a mock service provider object
# which you will use to set up your expectations. The method name to access the mock service provider
# will be what ever name you give as the service argument - in this case "my_service_provider"

require 'pact/consumer/rspec'

Pact.service_consumer "My Service Consumer" do
  has_pact_with "My Service Provider" do
    mock_service :my_service_provider do
      port 1234
    end
  end
end

# Use the :pact => true describe metadata to include all the pact generation functionality in your spec.

describe MyServiceProviderClient, :pact => true do

  before do
    # Configure your client to point to the stub service on localhost using the port you have specified
    MyServiceProviderClient.base_uri 'localhost:1234'
  end

  describe "get_text_from_something" do
    before do
      my_service_provider.
        .given("something exists")
        .upon_receiving("a request for something")
        .with( method: :get, path: '/something' )
        .will_respond_with(
          status: 200,
          headers: { 'Content-Type' => 'application/json' },
          body: {text: 'A thing!', something_else: 'Woot!'}
        )
    end

    it "returns the text from something" do
      # Use your service's client to make the request, rather than hand crafting a HTTP request,
      # so that you can be sure that the request that will be recorded in the pact file
      # is one that is actually made by your app.
      expect(MyServiceProviderClient.get_text_from_something).to eql("A thing!")
    end

  end

end

```

Running the consumer spec will generate a pact file in the configured pact dir (spec/pacts by default).
Logs will be output to the configured log dir that can be useful when diagnosing problems.

To run your consumer app as a process during your test (eg for a Capybara test):

```ruby
Pact.service_consumer "My Consumer" do
  app my_consumer_rack_app
  port 4321
end
```

### Service Provider project

#### Configure your service provider

Create a `pact_helper.rb` in your service provider project. The file must be called pact_helper.rb, however there is some flexibility in where it can be stored. The recommended place is `specs/service_providers/pact_helper.rb`.

```ruby
require 'my_app' # Require the boot files for your app
require 'provider_states_for_my_consumer' # See next section on setting up provider states

Pact.service_provider "My Service Provider" do
  app { MyApp.new }

  honours_pact_with 'My Service Consumer' do
    # This example points to a local file, however, on a real project with a continuous
    # integration box, you would publish your pacts as artifacts,
    # and point the pact_uri to the pact published by the last successful build.
    pact_uri '../path-to-your-consumer-project/specs/pacts/my_consumer-my_provider.json'
  end
end

```

#### Set up the service provider states

Having different service provider states allows you to test the same request with different expected responses.

For example, some code that creates the pact in a consumer project might look like this:

```ruby
my_service.
   given("a thing exists").
     upon_receiving("a request for a thing").
        with({method: 'get', path: '/thing'}).
          will_respond_with({status: 200, :body => {thing: "yay!"} })

my_service.
  given("a thing does not exist").
   upon_receiving("a request for a thing").
      with({method: 'get', path: '/thing'}).
        will_respond_with({status: 404, :body => {error: "There is no thing :("} })
```

To define service provider states that create the right data for "a thing exists" and "a thing does not exist", write the following in the service provider project.


```ruby
# The consumer name here must match the name of the consumer configured in your consumer project
# for it to correctly find these provider states.
# Make sure the provider states are included in or required by your pact_helper.rb file.

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
end

```

If a state should be used for all consumers, the top level Pact.with_consumer can be skipped, and a global Pact.provider_state can be defined on its own.

#### Verify that the service provider honours the pact

```ruby
  # In your Rakefile
  # If the pact gem is in the test/development section of your Gemfile, you may want to put an env check around this so it doesn't load the pact tasks in prod.
  require 'pact/tasks'
```

```
  $ rake -T
  rake pact:verify               # Verifies the pact files configured in the pact_helper.rb against this service provider.
  rake pact:verify:at[pact_uri]  # Verifies the pact at the given URI against this service provider.
  $ rake pact:verify
```

#### Verification using arbitrary pact files

```
# Local URI
$ rake pact:verify:at[../path-to-your-consumer-project/specs/pacts/my_consumer-my_provider.json]

# Remote URI
$ rake pact:verify:at[http://build-box/MyConsumerBuild/latestSuccessful/artifacts/my_consumer-my_provider.json]
```

To make a shortcut task for pact at an arbitrary URI, add the following to your Rakefile.

```ruby
# This creates a rake task that can be executed by running
# $rake pact:verify:dev
Pact::VerificationTask.new(:dev) do | pact |
  pact.uri '../path-to-your-consumer-project/specs/pacts/my_consumer-my_provider.json'
end
```

The pact.uri may be a local file system path or a remote URL.


## Pact best practices

### Ensure all calls to the provider go through your provider client class

Do not hand create any HTTP requests in your consumer app or specs. Testing through your provider client class gives you the assurance that your consumer app will be creating exactly the HTTP requests that you think it should.

### Do not stub your database calls in the provider project

This is the best time for you to test your database integration. If you stub your database calls, you are getting little more assurance that the real end-to-end will work than if you'd used a unit test. It's the appropriate time to incur the overhead of a database call.

### Use factories to create your expected models in your consumer project

Sure, you've checked that your client deserialises the HTTP response into the object you expect, but then you need to make sure in your other tests where you stub your client that you're stubbing it with a valid object. The best way to do this is to use factories for all your tests.

### Add pact:verify to your default rake task

It should run with all your other tests. If an integration is broken, you want to know about it *before* you check in.

### Publish your pacts as artifacts on your CI machine

Configure the pact_uri in the Pact.service_provider block with the pact artifact URL of your last successful build. This way you're only verifying green builds. No point verifying a broken one.
(Watch this space - pact-broker coming soon, so we don't have to use messy build box artifact URLs)


## Advanced

### Running a standalone mock server
A pact service can be run locally and is really useful for debugging purposes.

    $ bundle exec pact service -p <port-num>

The service prints messages it recieves to stdout which can be really useful
when diagnosing issues with pacts.

### Notes on pact file write mode

By default, the pact file will be overwritten (started from scratch) every time any rspec runs any spec using pacts. This means that if there are interactions that haven't been executed in the most recent rspec run, they are effectively removed from the pact file. If you have long running pact specs (e.g. they are generated using the browser with Capybara) and you are developing both consumer and provider in parallel, or trying to fix a broken interaction, it can be tedius to run all the specs at once. In this scenario, you can set the pactfile_write_mode to :update. This will keep all existing interactions, and update only the changed ones, identified by description and provider state. The down side of this is that if either of those fields change, the old interactions will not be removed from the pact file. As a middle path, you can set pactfile_write_mode to :smart. This will use :overwrite mode when running rake (as determined by a call to system using 'ps') and :update when running an individual spec.

### To use RSpec hooks for pact:verify

The pact:verify RSpec examples have the metadata `{:pact => :verify}` defined. You can add RSpec hooks using a filter as shown here:

```ruby
RSpec.configure do | config |
  config.before :each, :pact => :verify do
    # Your code here
  end
end
```

See https://www.relishapp.com/rspec/rspec-core/docs/hooks/filters for more information.

## TODO

Short term:
- FIX EXAMPLE!!!
- Make a pact-broker to store and return all the pacts, removing dependency on the CI box URLs.
- Provide a better work around for ActiveSupport JSON rubygems hell.

Long term:
- Provide more flexible matching (eg the keys should match, and the classes of the values should match, but the values of each key do not need to be equal). This is to make the pact verification less brittle.
- Decouple Rspec from Pact and make rspec-pact gem for easy integration

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
