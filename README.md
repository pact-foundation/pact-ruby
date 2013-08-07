# Pact

Define a pact between service consumers and providers.


Pact provides an RSpec DSL for service consumers to define the request they will make to a service producer and the
response they expect back. This expectation is used in the consumers specs to provide a mock producer, and is also
played back in the producer specs to ensure the producer actually does provide the response the consumer expects.

This allows you to test both sides of an integration point using fast unit tests.

## Installation

Put it in your Gemfile. You know how.

## Usage

### Consumer project

#### Configuration

Pact.configure do | config |
  config.pact_dir = "???" # Optional, default is ./spec/pacts
  config.log_dir = "???" # Optional, default is ./log
  config.logger = "??"
  config.logger.level = Logger::DEBUG #By default this is INFO, bump this up to debug for more detailed logs
end

#### Create a Consumer (Driven) Contract

```ruby
require 'pact/consumer/rspec'

class SomeServiceClient
  include HTTParty
  # Load your base_uri from a stub-able source
  base_uri App.configuration.some_service_base_uri

  def get_something
    JSON.parse(self.class.get("/something").body)
  end
end

Pact.configure do | config |
  config.consumer do
    name 'My Consumer'
  end
end

# The following block creates a service on localhost:1234 which will respond to your application's queries
# over HTTP as if it were the real "My Producer" app. It also creats a mock producer object
# which you will use to set up your expectations. The method name to access the mock producer
# will be what ever name you give as the service argument - in this case "my_producer"

Pact.with_producer "My Producer" do
  service :my_producer do
    port 1234
  end
end

# Use the :pact => true describe metadata to include all the pact generation functionality in your spec.

describe "a pact with My Producer", :pact => true do

  before do
    # Configure your client to point to the stub service on localhost using the port you have specified
    Application.configuration.stub(:some_service_base_uri).and_return('localhost:1234')
  end

  it "returns something when requested" do
    my_producer.
      given("something exists").
        upon_receiving("a request for something").
          with({ method: :get, path: '/something' }).
            will_respond_with({
              status: 200,
              headers: { 'Content-Type' => 'application/json' },
              body: {something: 'A thing!', something_else: 'Woot!'}
            })
    # Use your service's client to make the request, rather than hand crafting a HTTP request,
    # so that you can be sure that the request that you expect to
    # be constructed is actually constructed by your client.
    # Do a quick sanity test to ensure client passes back the response properly.
    expect(SomeServiceClient.get_something).to eql({something: 'A thing!'})
  end
end

```

Running the consumer spec will generate a pact file in the configured pact dir (spec/pacts by default).
Logs will be output to the configured log dir that can be useful when diagnosing problems.

To run your consumer app as a process during your test (eg for a Capybara test):

```ruby
Pact.configure do | config |
  config.consumer do
    name 'My Consumer'
    app my_consumer_rack_app
    port 4321
  end
```

### Producer project

#### Make the producer app available for the tests

```ruby
module AppUnderTest
  def app
    # Make your app available as a rack app here
  end
end

RSpec.configure do |config|
  config.include AppUnderTest
end

```

#### Set up the producer states

Having different producer states allows you to test the same request with different expected responses.

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

To define producer states that create the right data for "a thing exists" and "a thing does not exist", write the following in the producer project.
Note that these states have been defined only for the 'My Consumer' consumer by using the Pact.with_consumer block.


```ruby
# The consumer name here must match the name of the consumer configured in your consumer project
# for it to use these states.

Pact.with_consumer 'My Consumer' do
  producer_state "a thing exists" do
    set_up do
      # Create a thing here using your factory of choice
    end

    tear_down do
      # Any tear down steps to clean up your code (or use RSpec.after(:each))
    end
  end

  producer_state "a thing does not exist" do
    set_up do
      # Well, probably not much to do here, but you get the picture.
    end
  end
end

```

If a state should be used for all consumers, the top level Pact.with_consumer can be skipped, and a global Pact.producer_state can be defined on its own. 

#### Create a rake task to verify that the producer honours the pact

You'll need to create one or more pact:verify:xxx tasks, that allow the currently checked out producer to be tested against other versions of its consumers - most importantly, head and production.

Here is an example pact:verify:head task, pointing the the pact file for "some_consumer", found in the build artifacts of the latest successful build of "MY-CONSUMER" project.

```ruby
Pact::VerificationTask.new(:head) do | pact |
  pact.uri 'http://our_build_server/MY-CONSUMER-BUILD/latestSuccessful/artifact/Pacts/some_consumer-this_producer.json',
    support_file: './spec/consumers/pact_helper'
end
```

```ruby
# Ideally we'd like to be able to create a production task like this, but firewalls are making this tricky right now.
Pact::VerificationTask.new(:production) do | pact |
  pact.uri 'http://our_prod_server/pacts/some_consumer-this_producer.json',
    support_file: './spec/consumers/pact_helper', consumer: 'some_consumer'
end
```

The pact.uri may be a local file system path or a remote URL.

The consumer is optional, and specifies which consumer namespace to use when looking up the producer states, if consumer namespaces have been used.

The support_file should include the code that makes your rack app available for the rack testing framework, and should load all its dependencies (eg include spec_helper)

Multiple pact.uri may be defined in the same rake task if a producer has more than one consumer.

#### Verify that the producer honours the pact

    rake pact:verify:head
    rake pact:verify # will run all verify tasks


### Running a standalone mock server
A pact service can be run locally and is really useful for debugging purposes.

    $ bundle exec pact service -p <port-num>

The service prints messages it recieves to stdout which can be really useful
when diagnosing issues with pacts.

## TODO

Short term:
- Rename ConsumerContract to ConsumerContract (Done)
- Simplify set up for consumer (Done)
  - Move server spawning into to the "at" method (Done)
  - automatically register before and after hooks in consumer (Done)
- Provide before and after hooks and a place to define the app for Pact configuration in producer (remove Rspc from interface of Pact setup)
  - Set_up for state
  - Tear_down for state
  - Before hook for all
  - After hook for all
- Make producer state lookup try consumer defined state first, then fall back to global one
- Put producer and consumer name into pact file
- Remove consumer name from the rake task, as it should now be able to be determined from the pact file.

Long term:
- Decouple Rspec from Pact and make rspec-pact gem for easy integration


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
