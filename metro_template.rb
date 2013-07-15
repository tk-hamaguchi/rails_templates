add_source 'http://production.s3.rubygems.org'
gsub_file 'Gemfile', "source 'https://rubygems.org'", "#source 'https://rubygems.org'"
gsub_file 'Gemfile', /# (gem 'therubyracer'.*)/, '\1'
gsub_file 'Gemfile', /# (gem 'capistrano'.*)/, '\1'
gsub_file 'Gemfile', /# (gem 'bcrypt-ruby'.*)/, '\1'

gem 'twitter-bootstrap-rails'
gem 'less-rails'
gem 'less-rails-bootstrap'

gem 'devise'
gem 'simple_form'
gem 'kaminari'

gem_group :development do
  gem 'capistrano'
  gem 'thin'
end

gem_group :test do
  gem 'spring'
  gem 'rb-inotify', '~> 0.9'
  gem 'rspec-rails'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-cucumber'
end

gem_group :production do
  gem 'pg'
  gem 'unicorn'
end

run 'bundle install'

generate :controller, 'welcome index'
generate 'bootstrap:install', 'less'

gsub_file 'config/routes.rb', /# (root 'welcome#index')/, '\1'
