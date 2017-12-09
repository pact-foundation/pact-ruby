# Release process

* Unset X_PACT_DEVELOPMENT and bundle update if it was set.
* Ensure all tests are passing and everything is committed.
* Check status of https://travis-ci.org/pact-foundation/pact-ruby
* Run `script/release.sh [major|minor|patch]` (defaults to minor)
* Announce new version on @pact_up twitter account.
* Update any relevant wiki pages or documentation.
