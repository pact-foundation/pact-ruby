# Pact

Define a pact between service consumers and providers

## Installation

Add this line to your application's Gemfile:

    gem 'pact'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pact

## Usage

TODO: Write usage instructions here


## Keeping pacts up to date

Pacts are only useful when producers and consumers agree to the same terms.

    $ rake pact:pull


You'll need to set up the task with sources to make this work. In a Rakefile
(perhaps in `lib/tasks/pact.rake`), add something like the following:

    ```
    require 'pact/rake_task'

    Pact::RakeTask.new do |pact|
      pact.file 'spec/consumers/producer-consumer_development_pact.json',
        from_url: 'http://latestbuild.example.com/producer/producer-consumer_pact.json'

      pact.file 'spec/consumers/producer-consumer_production_pact.json
        from_url: 'http://producer.example.com/pacts/producer-consumer_pact.json'
    end
    ```

Run your tests with the new, updated pacts and commit them to source control.

    $ rake pact:pull && rake && git add -p

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
