RELEASE_NOTES_TEMPLATE_PATH = "packaging/RELEASE_NOTES.md.template"
RELEASE_NOTES_PATH = "build/RELEASE_NOTES.md"

desc 'Generate change log'
task :generate_changelog do
  require 'conventional_changelog'
  require 'pact/version'
  ConventionalChangelog::Generator.new.generate! version: "v#{Pact::VERSION}"
end
