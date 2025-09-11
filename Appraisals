appraise "rack-2" do
  gem "rack", "~> 2.0"

  group :test do
    remove_gem "rackup"
  end
end

appraise "activesupport" do
  gem "activesupport", "~> 5.1"
  if RUBY_VERSION >= "3.4"
    gem "csv"
    gem "mutex_m"
    gem "base64"
  end
end
