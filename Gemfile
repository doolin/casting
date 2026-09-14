source "https://rubygems.org"

gemspec

gem "codeclimate-test-reporter", require: nil
gem "minitest"
gem "rake"
gem "simplecov"
gem "standard"

# Audits the locked gems against the Ruby Advisory Database:
#   bundle exec bundle-audit check --update
gem "bundler-audit", require: false, groups: %i[development test]
