# Configuration

## Consumer and Provider

### diff_formatter

Default value: [:list](list)

Options: [:list](list), [:embedded](embedded), [:unix](unix) 

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

## Consumer


## Provider
