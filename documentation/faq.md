# Frequently asked questions

### How can I specify hooks to be executed before/after all examples for pact:verify?

The pact:verify RSpec examples have the metadata `{:pact => :verify}` defined. You can add RSpec hooks using a filter as shown here:

```ruby
RSpec.configure do | config |
  config.before :each, :pact => :verify do
    # Your code here
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

