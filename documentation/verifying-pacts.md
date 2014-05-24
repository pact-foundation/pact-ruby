# Verifying pacts

"Verifying a pact" is the second step of the Pact testing process. Each request in the pact file is replayed against 
the provider, and the response that is returned is compared with the expected response in the pact file, and if the two
match, then we know the consumer and provider are compatible.

To verify a pact, we must:

1. Configure the location of the pact to be verified. This can be a HTTP URL, or a local file system path.

2. Set up the data for the [provider states](/documentation/provider-states.md).

## Using rake pact:verify

Using the pact:verify task is the default way to verify pacts. It is made available by requiring `'pact/tasks'` in your Rakefile.

```ruby
# In Rakefile
require 'pact/tasks'
```

The pacts that will be verified by the pact:verify task are configured in the pact_helper.rb file in your provider codebase.
The file must be called pact_helper.rb, however there is some flexibility in where it can be stored.
The recommended place is `spec/service_consumers/pact_helper.rb`.

To ensure that the latest version of the consumer pact is used each time, it is recommended that you either use a [Pact Broker](https://github.com/bethesque/pact_broker)
or that you publish the pacts of a successful consumer build as artefacts in your CI system.

```ruby
# In specs/service_consumers/pact_helper.rb

require 'pact/provider/rspec'

Pact.service_provider "My Service Provider" do

  app { MyApp.new } # Optional, loads app from config.ru by default

  honours_pact_with 'My Service Consumer' do

    # This example points to a local file, however, on a real project with a continuous
    # integration box, you would publish your pacts as artifacts,
    # and point the pact_uri to the pact published by the last successful build.

    pact_uri '../path-to-your-consumer-project/specs/pacts/my_consumer-my_provider.json'
  end

  # This block is repeated for every pact that this provider should be verified against.
  honours_pact_with 'Some other Service Consumer' do
    ...
  end  
  
end
```

## Using rake pact:verify:at

You can also verify a pact at any arbitrary local or remote URL using the `pact:verify:at` task.
This is useful when you are writing the consumer and provider concurrently, and wish to 

    $ rake pact:verify:at[../path-to-your-consumer-project/specs/pacts/my_consumer-my_provider.json]
    $ rake pact:verify:at[http://build-box/MyConsumerBuild/latestSuccessful/artifacts/my_consumer-my_provider.json]


## Using a custom pact:verify task

To make a shortcut task for verifying a pact an arbitrary URL that you do not want to verify as part of your normal pact:verify task,
(eg. when you are developing the consumer and provider side by side, and want a shorter feedback cycle than can be provided by
by your CI box) add the following to your Rakefile. The pact.uri may be a local file system path or a remote URL.

```ruby
# In Rakefile or /tasks/pact.rake

# This creates a rake task that can be executed by running
# $ rake pact:verify:dev

Pact::VerificationTask.new(:dev) do | pact |
  pact.uri '../path-to-your-consumer-project/specs/pacts/my_consumer-my_provider.json'
end
```

## Running one pact at a time

At some stage, you'll want to be able to run your specs one at a time while you implement each feature. At the bottom of the failed pact:verify output you will see the commands to rerun each failed interaction individually. A command to run just one interaction will look like this:

    $ rake pact:verify PACT_DESCRIPTION="a request for something" PACT_PROVIDER_STATE="something exists"

## Pact Helper location

The search paths for the pact_helper are:

```ruby
[
  "spec/**/*service*consumer*/pact_helper.rb",
  "spec/**/*consumer*/pact_helper.rb",
  "spec/**/pact_helper.rb",
  "**/pact_helper.rb"]
```
