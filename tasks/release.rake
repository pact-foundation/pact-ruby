RELEASE_NOTES_TEMPLATE_PATH = "packaging/RELEASE_NOTES.md.template"
RELEASE_NOTES_PATH = "build/RELEASE_NOTES.md"

desc 'Generate change log'
task :generate_changelog do
  require 'conventional_changelog'
  require 'pact/version'
  ConventionalChangelog::Generator.new.generate! version: "v#{Pact::VERSION}"
end

desc 'Tag for release'
task :tag_for_release do | t, args |
  command = "git tag -a v#{Pact::VERSION} -m \"chore(release): version #{Pact::VERSION}\" && git push origin v#{Pact::VERSION}"
  puts command
  puts `#{command}`
end
