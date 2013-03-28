source "https://rubygems.org"

gem 'yajl-ruby', require: 'yajl'
gem 'multi_json'
gem 'rmmseg-cpp', require: 'rmmseg'
gem 'em-synchrony'
gem 'activesupport', require: [
  'active_support/core_ext/hash/slice',
  'active_support/core_ext/hash/except',
  'active_support/core_ext/time/calculations',
  'active_support/core_ext/numeric/time',
  'active_support/core_ext/integer/time'
]
gem 'rufus-scheduler'
gem 'fazscore', git: 'git://github.com/transist/fazscore.git'

gem 'goliath', require: false

gem 'echidna-env', path: 'echidna-env', require: 'echidna/all'

group :development, :test do
  gem 'awesome_print'
  gem 'pry'
  gem 'pry-stack_explorer'
  gem 'pry-nav'
end

group :test do
  gem 'rspec'
end
