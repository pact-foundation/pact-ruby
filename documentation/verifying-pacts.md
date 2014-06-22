# Verifying pacts

"Verifying a pact" is the second step of the Pact testing process. Each request in the pact file is replayed against 
the provider, and the response that is returned is compared with the expected response in the pact file, and if the two
match, then we know the consumer and provider are compatible.

To verify a pact, we must:

1. Configure the location of the pact to be verified. This can be a HTTP URL, or a local file system path.
1. Set up the data for the [provider states](/documentation/provider-states.md).
1. Optionally, configure the service provider app that will be used to run the requests against. 


## Using rake pact:verify

Using the `pact:verify` task is the most common way to verify pacts. This is where you configure the default set of pacts that your service provider should honour.

It is made available by requiring `'pact/tasks'` in your Rakefile.

```ruby
# In Rakefile
require 'pact/tasks'

# Remember to add it to your default Rake task
task :default => 'pact:verify'

```

The pacts that will be verified by the `pact:verify` task are configured in the `pact_helper.rb` file in your provider codebase.
The file must be called `pact_helper.rb`, however there is some flexibility in where it can be stored.
The recommended place is `spec/service_consumers/pact_helper.rb`.

To ensure that the latest version of the consumer pact is used each time, it is recommended that you either use a [Pact Broker](https://github.com/bethesque/pact_broker)
or that you publish the pacts of a successful consumer build as artefacts in your CI system.

Note: Pact uses Rack::Test, and assumes that your service provider will be a Rack app. See below for options if your provider is not a Rack app.

```ruby
# In specs/service_consumers/pact_helper.rb

require 'pact/provider/rspec'

# Require the provider states files for each service consumer
require 'service_consumers/provider_states_for_my_service_consumer'

Pact.service_provider "My Service Provider" do

  # Optional app configuration. Pact loads the app from config.ru by default 
  # (it is recommended to let Pact use the config.ru if possible, so testing 
  # conditions are closest to runtime conditions)
  app { MyApp.new }

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

## Verifying a pact at any URL using rake pact:verify:at

You can verify a pact at any arbitrary local or remote URL using the `pact:verify:at` task.
This is useful when you are developing the consumer and provider concurrently, and wish to verify the pact you have just generated in the consumer code base. It will use the same pact_helper file as `pact:verify`.

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

Pact::VerificationTask.new(:dev) do | task |
  task.uri '../path-to-your-consumer-project/specs/pacts/my_consumer-my_provider.json'
end
```

## Verifying one interaction at a time

At some stage, you'll want to be able to run your specs one at a time while you implement each feature. At the bottom of the failed pact:verify output you will see the commands to rerun each failed interaction individually. A command to run just one interaction will look like this:

    $ rake pact:verify PACT_DESCRIPTION="a request for something" PACT_PROVIDER_STATE="something exists"

## Verifying pacts for non-Rack apps

### Ruby apps
If your app is a non-Rack Ruby app, you may be able to find a Rack adapter for it. If you can do this, then configure the `app` in the `Pact.service_provider` block to point to an instance of your adapter. Otherwise, use the [pact-provider-proxy](https://github.com/bethesque/pact-provider-proxy) gem. 

### JVM apps

Use [pact-jvm](https://github.com/DiUS/pact-jvm).

### Other apps
Use the [pact-provider-proxy](https://github.com/bethesque/pact-provider-proxy) gem


## Configuring RSpec

Pact uses dynamically created RSpec specs to verify pacts. If you want to modify the behaviour of the underlying RSpec execution, you can:

1. Configure RSpec in the pact_helper using the normal `RSpec.configure` code.
1. Set `task.rspec_opts` in your custom rake VerificationTask, the same way you would with a normal RSpec rake task declaration.

For future proofing though, try to use the provider state set_up/tear_down blocks where you can, because we may swap out RSpec for custom verification code in the future.

## Pact Helper location

The search paths for the pact_helper are:

```ruby
[
  "spec/**/*service*consumer*/pact_helper.rb",
  "spec/**/*consumer*/pact_helper.rb",
  "spec/**/pact_helper.rb",
  "**/pact_helper.rb"]
```
