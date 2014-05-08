## Gotchas

* Be aware when using the app from the config.ru file is used (the default option) that the Rack::Builder.parse_file seems to require files even if they have already been required, so make sure your boot files are idempotent.

