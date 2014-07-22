# Model Factories
It's about ensuring the model used to stub client responses can actually be produced by the response you expect. Imagine your client returns a model like so:

```ruby
class MyModel
   attr_reader :timestamp
   
   def initialize attrs
      @timestamp = attr[:timestamp]
   end
end
```

In your unit test for the client, you expect that it returns an instance of the model with the timestamp that is a Time

```ruby
expect(my_client.get_my_model).to eq(MyModel.new(timestamp: Time.new(2014, 06, 04, 01, 21, 54)))
```

But then you stub the client in another test to return a model, but here you expect the timestamp to be a DateTime (hypothetically, not that anyone I know has every done anything like this...)

```ruby
allow(my_client).to receive(:get_my_model).and_return(MyModel.new(timestamp: DateTime.parse('2014-06-04T01:21:54+00:00'))
```

There is no test that will fail to alert you of the error. If you use a shared fixture or consistent way of creating the object so that the thing you stub with has been validated by the pact test as something that will actually be created, you won't have this problem.

```ruby
# Maybe something like:

class MyModelFactory
   def self.create_my_model attrs
      #Do something to ensure that the timestamp is the right class
   end
end
```

Typed languages of course don't have this problem. One of the downsides of Ruby.

It's actually a repeat of the pattern that pact is based on - when you mock, you need some way to verify that your mocks are correct.
