source 'https://rubygems.org'

gem 'httpi'
gem 'cuba'
gem 'json'
#gem 'sequel'
gem 'rack-protection', :require => 'rack/protection'
gem 'cuba-sugar', :require => false
if defined? JRUBY_VERSION
  gem 'jruby-openssl'
  #gem 'jdbc-sqlite3'
  gem 'mizuno'
  gem 'warbler', :require => false
else
  #gem 'sqlite3'
  gem 'thin'
end
