# Frequently asked questions

### How can I verify a pact against a non-ruby provider?

You can verify a pact against any running server, regardless of language, using [pact-provider-proxy](https://github.com/bethesque/pact-provider-proxy).

There is also a JVM version of pact under development. Have a look at [pact-jvm](https://github.com/DiUS/pact-jvm), the that contains the equivalent of pact/consumer and pact/provider.

### How can I create a pact for a consumer that is not ruby or on the JVM?

Become famous, and write a pact-consumer library yourself! Then let us know about it so we can put a link to it in the documentation.

### How can I specify hooks to be executed before/after all examples for pact:verify?

Use the set_up and tear_down hooks in the provider state definition:

```ruby

Pact.provider_states_for "Some Consumer" do

  set_up do
    # Set up code here 
  end

  tear_down do
    # tear down code here
  end

end
```

See https://www.relishapp.com/rspec/rspec-core/docs/hooks/filters for more information.

### How can I run my consumer UI during my consumer specs so I can execute the tests using a browser?

Eg. for Capybara tests

```ruby
Pact.service_consumer "My Consumer" do
  app <your rack app here>
  port 4321
end
```

### Should the database or any other part of the provider be stubbed?

This is a hotly debated issue.

The pact authors' experience with using pacts to test microservices has been that using the set_up hooks to populate the database, and running pact:verify with all the real provider code has worked very well, and gives us full confidence that the end to end scenario will work in the deployed code.

However, if you have a large and complex provider, you might decide to stub some of your application code. If you do, remember to add your own "verification" of your stubbed methods - write another test that will break if the behaviour of the stubbed methods changes.

### Why are the pacts generated and not hand coded?

* Maintainability: Pact is "contract by example", and the examples may involve large quantities of JSON. Maintaining the JSON files by hand would be both time consuming and error prone. By dynamically creating the pacts, you have the option to keep your expectations in fixture files, or to generate them from your domain (the recommended approach, as it ensures your domain objects and their JSON representations in the pacts can never get out of sync).

* Provider states: Dynamically setting expectations on the mock server allows the use of provider states, meaning you can make the same request more than once, with different expected responses, allowing you to properly test all your code paths.
