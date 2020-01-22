#!/bin/bash
set -e
unset X_PACT_DEVELOPMENT
bundle exec bump ${1:-minor} --no-commit
bundle exec rake generate_changelog
git add CHANGELOG.md lib/pact/version.rb
git commit -m "chore(release): version $(ruby -r ./lib/pact/version.rb -e "puts Pact::VERSION")" && git push
bundle exec rake tag_for_release

