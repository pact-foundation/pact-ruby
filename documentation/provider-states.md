# Provider States

Provider states allow you to set up data on the provider before the interaction is run, so that it can make a response that matches what the consumer expects. It also allows the consumer to make the same request with different expected responses.

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
      # Stubbing is ususally the easiest way to generate an error with predictable error text.
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