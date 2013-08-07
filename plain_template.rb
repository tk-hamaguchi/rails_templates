@heroku_flag = true if yes? "Would you like to use heroku?"

git :init
git add: '.'
git commit: '-a -m "first commit."'

add_source 'http://production.s3.rubygems.org'
gsub_file 'Gemfile', "source 'https://rubygems.org'", "#source 'https://rubygems.org'"
gsub_file 'Gemfile', /# (gem 'therubyracer'.*)/, '\1'
gsub_file 'Gemfile', /# (gem 'capistrano'.*)/, '\1'
gsub_file 'Gemfile', /# (gem 'bcrypt-ruby'.*)/, '\1'

gem 'devise', '~> 3.0.0'
gem 'devise-i18n'
gem 'simple_form'
gem 'kaminari'
gem 'rails_config'
gem 'paranoia'

gem_group :development do
  gem 'thin'
  gem 'capistrano-ext'
  gem 'capistrano_colors'
  gem 'capistrano-unicorn'
end

gem_group :test do
  gem 'spring'
  gem 'rb-inotify', '~> 0.9'
  gem 'rspec-rails'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'faker-japanese'
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-cucumber'
end

gem_group :production do
  gem 'unicorn'
end

run 'bundle install'


gsub_file 'config/application.rb', /^# require "rails\/test_unit\/railtie"$/, ''
gsub_file 'config/application.rb', /^( +)# (config.time_zone = ).+$/, '\1\2"Tokyo"'
gsub_file 'config/application.rb', /^( +)# (config.i18n.default_locale = ).+$/, '\1\2:ja'


inside('config/locales') do
  run 'curl -O https://raw.github.com/svenfuchs/rails-i18n/master/rails/locale/en.yml -O https://raw.github.com/svenfuchs/rails-i18n/master/rails/locale/ja.yml'
end

file "config/locales/#{app_name}.en.yml", <<-CODE
en:
  app_name: #{app_name.camelize}
CODE

file "config/locales/#{app_name}.ja.yml", <<-CODE
ja:
  app_name: #{app_name.camelize}
CODE



generate 'rspec:install'
gsub_file 'config/application.rb', /^  end\nend$/, "\n    config.generators do |g|\n      g.test_framework      :rspec\n      g.integration_tool    :rspec\n      g.fixture_replacement :factory_girl, dir:'spec/factories'\n    end\n  end\nend"

generate 'cucumber:install'

run 'guard init'


generate 'rails_config:install'
generate 'kaminari:config'
generate 'kaminari:views', 'default'
generate 'simple_form:install'
generate 'devise:install', '-q'

environment "config.action_mailer.default_url_options = { host: 'localhost:3000' }"


generate :controller, 'welcome index'
gsub_file 'config/routes.rb', /# (root 'welcome#index')/, '\1'
gsub_file 'config/routes.rb', /^ +get "welcome\/index"$/, ''

generate 'devise:views'
generate :devise, 'User', 'name:string', 'deleted_at:datetime', 'lock_version:integer'

insert_into_file "app/views/layouts/application.html.erb", "<%= render partial: 'devise/shared/links', locals: {resource_name: User, devise_mapping:Devise.mappings[:user]} %>\n", after: "<!--/.well -->\n"

generate :controller, 'my', 'top'
gsub_file 'config/routes.rb', /^ +get "my\/top"$/, '  get "my" => "my#top"'


insert_into_file 'app/controllers/my_controller.rb', "  before_filter :authenticate_user!\n", after: "ApplicationController\n"

insert_into_file 'app/controllers/welcome_controller.rb', "\n\n  private\n\n    def redirect_to_my_top\n      redirect_to my_path if user_signed_in?\n    end\n", after: "  end"
insert_into_file 'app/controllers/welcome_controller.rb', "\n  before_filter :redirect_to_my_top\n\n", before: "  def index"

file 'lib/tasks/rspec.rake', <<-CODE
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)
CODE


rake "db:create"

run 'mkdir -p misc/capistrano'

inside('misc/capistrano') do
  run 'capify .'
end
