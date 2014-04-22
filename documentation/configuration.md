# Configuration

## Menu

#### Consumer and Provider configuration options
* [diff_formatter](#diff_formatter)
* [log_dir](#log_dir)
* [logger](#logger)
* [logger.level](#logger.level)

#### Consumer only configuration options
* [pact_dir](#pact_dir)
* [doc_dir](#doc_dir)
* [doc_generator](#doc_generator)
* [pactfile_write_mode](#pactfile_write_mode)

#### Provider only configuration options
* [include](#include)

## Consumer and Provider

### log_dir

Default value: `./log`

### logger

Default value: file logger to the configured log_dir.

### logger.level

Default value: `Logger::DEBUG`

### diff_formatter

Default value: [:list](#list)

Options: [:list](#list), [:embedded](#embedded), [:unix](#unix), [Custom Diff Formatter](#custom-diff-formatter)

```ruby
Pact.configure do | config |
  config.diff_formatter = :list
end
```

#### :list

<img src="diff_formatter_list.png" width="700">

#### :embedded

<img src="diff_formatter_embedded.png" width="700">

#### :unix
<img src="diff_formatter_unix.png" width="700">

#### Custom Diff Formatter

Any object can be used that responds to `call`, accepting the argument `diff`.

```ruby
class MyCustomDiffFormatter

  def self.call diff
    ### Do stuff here
  end

end

Pact.configure do | config |
  config.diff_formatter = MyCustomDiffFormatter
end
```


## Consumer

### pact_dir

Default value: `./spec/pacts`

### doc_generator

Default value: none

Options: [:markdown](#markdown), [Custom Doc Generator](#custom-doc-generator)

```ruby
Pact.configure do | config |
  config.doc_generator = :markdown
end
```

#### :markdown

Generates Markdown documentation based on the contents of the pact files created in this consumer. Files are created in `${Pact.configuration.doc_dir}/markdown`.

#### Custom Doc Generator

Any object can be used that responds to `call`, accepting the arguments `pact_dir` and `doc_dir`.

```ruby
Pact.configure do | config |
  config.doc_generator = lambda{ | pact_dir, doc_dir | generate_some_docs(pact_dir, doc_dir) }
end

```

#### doc_dir

Default value: `./doc`

```ruby
Pact.configure do | config |
  config.doc_generator = './documentation'
end
```

### pactfile_write_mode

Default value: `:overwrite`
Options: `:overwrite`, `:update`, `:smart`

By default, the pact file will be overwritten (started from scratch) every time any rspec runs any spec using pacts. This means that if there are interactions that haven't been executed in the most recent rspec run, they are effectively removed from the pact file. If you have long running pact specs (e.g. they are generated using the browser with Capybara) and you are developing both consumer and provider in parallel, or trying to fix a broken interaction, it can be tedious to run all the specs at once. In this scenario, you can set the pactfile_write_mode to :update. This will keep all existing interactions, and update only the changed ones, identified by description and provider state. The down side of this is that if either of those fields change, the old interactions will not be removed from the pact file. As a middle path, you can set pactfile_write_mode to :smart. This will use :overwrite mode when running rake (as determined by a call to system using 'ps') and :update when running an individual spec.

## Provider

Pact uses RSpec and Rack::Test to create dynamic specs based on the pact files. RSpec configuration can be used to modify test behaviour if there is not an appropriate Pact feature. If you wish to use the same spec_helper.rb file as your unit tests, require it in the pact_helper.rb, but remember that the RSpec configurations for your unit tests may or may not be what you want for your pact verification tests.

### include

To make modules available in the provider state set_up and tear_down blocks, include them in the configuration as shown below. One common use of this is to include RSpec::Mocks::ExampleMethods to make the `allow()` method available.


```ruby
Pact.configure do | config |
  config.include RSpec::Mocks::ExampleMethods
end
```
