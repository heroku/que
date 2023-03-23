source 'https://rubygems.org'

group :development, :test do
  gem 'rake', '< 11.0'

  gem 'activerecord',    :require => nil
  gem 'sequel',          :require => nil
  gem 'connection_pool', :require => nil
  gem 'pond', '~> 0.5.0',:require => nil
  gem 'pg',              :require => nil, :platform => :ruby
  gem 'pg_jruby',        :require => nil, :platform => :jruby
end

group :test do
  gem 'rspec', '~> 2.14.1'
  gem 'pry'
  gem 'bigdecimal', '1.3.5'
end

platforms :rbx do
  gem 'rubysl', '~> 2.0'
  gem 'json', '~> 1.8'
end

gemspec
