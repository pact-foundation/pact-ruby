# How to roll your own Doc Generator

1. Create a ConsumerContractRenderer that responds to `call` and accepts a `ConsumerContract` (this is the name for the domain model of a "pact"). This should return a String. For an example, see the [Markdown::ConsumerContractRenderer][consumer_contract_renderer].
2. Create an IndexRenderer. This allows you to create an index file for your docs. It should respond to `call` and accept the String name of the consumer, and a hash of Hash of `pact title => file_name`, and return a String. For an example, see the [Markdown::IndexRenderer][index_renderer].
3. Create a Generator. This is responsible for the overall file generating and writing process. Copy the [Markdown::Generator][generator] and configure it with your own ConsumerContractRenderer, IndexRenderer and file details.

If you would like to generate HTML documentation, see how the [HTMLPactRenderer][html_pact_renderer] in the Pact Broker does it.

[consumer_contract_renderer]: https://github.com/realestate-com-au/pact/blob/master/lib/pact/doc/markdown/consumer_contract_renderer.rb
[index_renderer]: https://github.com/realestate-com-au/pact/blob/master/lib/pact/doc/markdown/index_renderer.rb
[generator]: https://github.com/realestate-com-au/pact/blob/master/lib/pact/doc/markdown/generator.rb
[html_pact_renderer]: https://github.com/bethesque/pact_broker/blob/master/lib/pact_broker/api/renderers/html_pact_renderer.rb

