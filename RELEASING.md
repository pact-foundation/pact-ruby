# Release process

* Unset X_PACT_DEVELOPMENT if it was set.
* Ensure all tests are passing and everything is committed.
* Update lib/pact/version.rb
* `bundle update`
* `bundle exec appraisal update`
* `bundle exec rake`
* Update CHANGELOG.md
 * Generate the git log using the command shown in the CHANGELOG.md
 * Delete commit comments that won't be interesting for a user of the gem (refactorings, tests etc).
* `git add CHANGELOG.md lib/pact/version.rb gemfiles`
* `git commit -m "chore(release): version $(ruby -r ./lib/pact/version.rb -e "puts Pact::VERSION")" && git push`
* `bundle exec rake release`
* Announce new version on @pact_up twitter account.
* Update any relevant wiki pages or documentation.
