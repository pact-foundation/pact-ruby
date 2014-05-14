# Frequently asked questions

### How does Pact differ from VCR?

Pact is like VCR in reverse. VCR records actual provider behaviour, and verifies that the consumer behaves as expected. Pact records consumer behaviour, and verifies that the provider behaves as expected. The advantages Pact provides are:

* The ability to develop the consumer (eg. a Javascript rich client UI) before the provider (eg. the JSON backend API).
* The ability to drive out the requirements for your provider first, meaning you implement exactly and only what you need in the provider.
* Well documented use cases ("Given ... a request for ... will return ...") that show exactly how a provider is being used.
* The ability to see exactly which fields each consumer is interested in, allowing unused fields to be removed, and new fields to be added in the provider API without impacting a consumer. 
* The ability to immediately see which consumers will be broken if a change is made to the provider API.
* When using the [Pact Broker](https://github.com/bethesque/pact_broker), the ability to map the relationships between your services.

### How does Pact differ from Webmock?

Unlike Webmock:

* Pact provides verification that the responses that have been stubbed are actually the responses that will be returned in the given conditions.
* Pact runs a mock server in an actual process, rather than intercepting requests within the Ruby code, allowing Javascript rich UI clients to be tested in a browser.

### How can I handle versioning?

Consumer driven contracts to some extent allows you to do away with versioning. As long as all your contract tests pass, you should be able to deploy changes without versioning the API. If you need to make a breaking change to a provider, you can do it in a multiple step process - add the new fields/endpoints to the provider and deploy. Update the consumers to use the new fields, then deploy. Remove the old fields/endpoints from the provider and deploy. At each step of the process, all the contract tests remain green.

Using a [Pact Broker]((https://github.com/bethesque/pact_broker), you can tag the production version of a pact when you make a release of a consumer. Then, any changes that you make to the provider can be checked agains the production version of the pact, as well as the latest version, to ensure backward compatiblity.

If you need to support multiple versions of the provider API concurrently, then you will probably be specifying which version your consumer uses by setting a header, or using a different URL component. As these are actually different requests, the interactions can be verified in the same pact without any problems.

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

However, if you have a large and complex provider, you might decide to stub some of your application code. You will definitly need to stub calls to downstream systems. Make sure, when you stub, that you don't stub the code that actually parses the requests, because otherwise the consumer could be sending absolute rubbish, and you won't be checking it.

### Why are the pacts generated and not hand coded?

* Maintainability: Pact is "contract by example", and the examples may involve large quantities of JSON. Maintaining the JSON files by hand would be both time consuming and error prone. By dynamically creating the pacts, you have the option to keep your expectations in fixture files, or to generate them from your domain (the recommended approach, as it ensures your domain objects and their JSON representations in the pacts can never get out of sync).

* Provider states: Dynamically setting expectations on the mock server allows the use of provider states, meaning you can make the same request more than once, with different expected responses, allowing you to properly test all your code paths.
