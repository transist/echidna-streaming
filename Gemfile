source "https://rubygems.org"

gem 'yajl-ruby', require: 'yajl'
gem 'multi_json'
gem 'rmmseg-cpp', require: 'rmmseg'
gem 'em-synchrony'
gem 'activesupport', require: [
  'active_support/core_ext/hash/slice',
  'active_support/core_ext/hash/except',
  'active_support/core_ext/time/calculations'
]

gem 'goliath', require: false

gem 'echidna-ruby', git: "git@github.com:transist/echidna-ruby.git",
                    require: ['echidna/path', 'echidna/logger', 'echidna/redis']

group :test do
  gem 'rspec'
end
