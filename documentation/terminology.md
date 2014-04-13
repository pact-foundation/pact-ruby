# Terminology

### Service Consumer

A component that initiates a HTTP request to another component (the service provider). Note that this does not depend on the way the data flows - whether it is a GET or a PUT/POST/PATCH, the consumer is the initiator of the HTTP request.

### Service Provider

A server that responds to an HTTP request from another component (the service consumer).

### Mock Service Provider

Used by tests in the consumer project to mock out the actual service provider, meaning that integration-like tests can be run without requiring the actual service provider to be available.

### Pact file

A file containing the JSON serialised requests and responses that were defined in the consumer tests.

### Pact verification

To verify a pact, the requests contained in a pact file are replayed against the provider code, and the responses returned are checked to ensure they match those expected in the pact file.

### Provider state

A name describing a "state" (like a fixture) that the provider should be in when a given request is replayed against it. Eg. "there is an alligator called Mary" or "there are no alligators". A provider state name is specified when writing the consumer specs, then, when the pact verification is set up in the provider, the same name will be used to identify the set up code block that should be run before the request is executed.
