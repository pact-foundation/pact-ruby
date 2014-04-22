# Rarely asked questions

### How can I run a standalone mock server?

By default, a mock service will be started automatically by the pact gem when running the consumer tests. A standalone mock service can be run locally and is useful for debugging purposes.

```ruby
Pact.service_consumer "My Service Consumer" do
  has_pact_with "My Service Provider" do
    mock_service :my_service_provider do
      port <port-num>
      standalone true #Tell the pact gem not to automatically start the mock service
    end
  end
end
```
    $ bundle exec pact service -p <port-num>

The service prints messages it recieves to stdout which can be really useful
when diagnosing issues with pacts.

### Doesn't this break HAL?

Yes.

### How can I specify multiple headers with the same name?

RFC 2616 states that two headers with the same name can interpreted as a single header with two comma-separated values. This is the safest way to specify multiple headers with the same name, as Rack will only pass the last value through when they are defined separately (see https://github.com/rack/rack/issues/436).

```ruby
my_service_provider.
  .given("it is RFC 2616 compliant")
  .upon_receiving("a request with a header with commas separated values")
  .with( method: :get, path: '/', headers: {'X-Request-Multival' => "A, B"} )
  .will_respond_with(
    status: 200, headers: {'X-Response-Multival' => "C, D"}
  )

```
