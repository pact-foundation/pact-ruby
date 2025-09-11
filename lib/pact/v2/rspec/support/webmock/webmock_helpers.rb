# frozen_string_literal: true

module WebmockHelpers
  def self.turned_off
    yield unless defined?(::WebMock)

    allow_net_connect = WebMock::Config.instance.allow_net_connect
    allow_localhost = WebMock::Config.instance.allow_localhost
    allow_hosts = WebMock::Config.instance.allow
    net_http_connect_on_start = WebMock::Config.instance.net_http_connect_on_start

    return yield if allow_net_connect

    WebMock.allow_net_connect!

    result = yield

    # disable_net_connect! resets previous config settings
    # so we need to specify them explicitly
    WebMock.disable_net_connect!(
      {
        allow_localhost: allow_localhost,
        allow: allow_hosts,
        net_http_connect_on_start: net_http_connect_on_start
      }
    )

    result
  end
end
