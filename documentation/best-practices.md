# Pact best practices

## In your consumer project

#### Publish your pacts as artifacts on your CI machine or use a [Pact Broker](https://github.com/bethesque/pact_broker)

Either of these techniques makes the pact available via URL, which your provider build can then use when it runs pact:verify. This means your provider will always be verified against the latest pact from your consumer.

#### Ensure all calls to the provider go through your provider client class

Do not hand create any HTTP requests in your consumer app or specs. Testing through your provider client class gives you the assurance that your consumer app will be creating exactly the HTTP requests that you think it should.

#### Ensure the models you stub with are valid

Sure, you've checked that your client deserialises the HTTP response into the object you expect, but then you need to make sure in your other tests where you stub your client that you're stubbing it with a valid object (eg. is `time` a Time or a DateTime?). One way to do this is to use factories or fixtures to create the models for all your tests. See this [gist](https://gist.github.com/bethesque/69ae590e8312523e5337) for a more detailed explanation.

## In your provider project

#### Retrieve pacts from the [Pact Broker](https://github.com/bethesque/pact_broker) or use the pact artifact published by your consumer's CI build

Configure the pact_uri in the Pact.service_provider block with the pact URL of your last successful build, whether that's from the pact broker, or your CI build. This way you're only verifying green builds. No point verifying a broken one.

#### Add pact:verify to your default rake task

It should run with all your other tests. If an integration is broken, you want to know about it *before* you check in.

#### In pact:verify on the provider, only stub layers beneath where contents of the request body are extracted

If you don't _have_ to stub anything in the provider when running pact:verify, then don't. If you do need to stub something, make sure that you only stub the code that gets executed _after_ the contents of the request body have been extracted and/or validated, otherwise, there is no verification that what is included in the body of a request matches what is actually expected.

#### Stub calls to downstream systems

Consider making a separate pact with the downstream system and using shared fixtures.
