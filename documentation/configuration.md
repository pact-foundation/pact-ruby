# Configuration

## Consumer and Provider

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


## Provider
