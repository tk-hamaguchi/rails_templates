#####
##
## Plain Template for Rails4
##
## @author @tk_hamaguchi
## @examples Generate with template
##   $ rails new my_app -T --skip-bundle -m https://github.com/tk-hamaguchi/rails_templates/blob/master/bootsttap_template.rb
##
#


## Create and initialize Git repository.
git :init
git add: '.'
git commit: '-a -m "first commit."'


## Update gem source.
add_source 'http://production.s3.rubygems.org'
gsub_file 'Gemfile', "source 'https://rubygems.org'", "#source 'https://rubygems.org'"
gsub_file 'Gemfile', /# (gem 'therubyracer'.*)/, '\1'
gsub_file 'Gemfile', /# (gem 'capistrano'.*)/, '\1'
gsub_file 'Gemfile', /# (gem 'bcrypt-ruby'.*)/, '\1'


## Add gem files.
gem 'devise'
gem 'devise-i18n'
gem 'simple_form'
gem 'kaminari'
gem 'rails_config'
gem 'paranoia'
gem 'puma'
gem 'bootstrap-sass'
gem 'font-awesome-sass'




gem_group :test do
  gem 'spring'
  gem 'rb-inotify', '~> 0.9'
  gem 'rspec-rails'
  gem 'poltergeist'
  gem 'turnip'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'faker-japanese'
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-cucumber'
end


## Execute bundle install
run 'bundle install'


## Configure rails locales.
gsub_file 'config/application.rb', /^# require "rails\/test_unit\/railtie"$/, ''
gsub_file 'config/application.rb', /^( +)# (config.time_zone = ).+$/, '\1\2"Tokyo"'
gsub_file 'config/application.rb', /^( +)# (config.i18n.default_locale = ).+$/, '\1\2:ja'

inside('config/locales') do
  run 'curl -O https://raw.github.com/svenfuchs/rails-i18n/master/rails/locale/en.yml -O https://raw.github.com/svenfuchs/rails-i18n/master/rails/locale/ja.yml'
end

file "config/locales/#{app_name}.en.yml", <<-CODE
en:
  app_name: #{app_name.camelize}
  sign_in: Sign in
  sign_up: Sign up
  sign_out: Sign out
  edit_user_registration: Edit Profile
CODE

file "config/locales/#{app_name}.ja.yml", <<-CODE
ja:
  app_name: #{app_name.camelize}
  sign_in: 'ログイン'
  sign_up: '新規登録'
  sign_out: 'ログアウト'
  edit_user_registration: 'ユーザー設定'
CODE

file "config/initializers/i18n.rb", <<-CODE
  I18n.enforce_available_locales = false
CODE

file "config/puma.rb", <<-CODE
environment ENV['RACK_ENV']
threads 0,5

#workers 3
preload_app!

on_worker_boot do
  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.establish_connection
  end
end
CODE



## Configure bootstrap-sass
gsub_file 'app/assets/javascripts/application.js',  /^\/\/= require_tree \.$/,  "//= require bootstrap\n//= require_tree ."
gsub_file 'app/assets/stylesheets/application.css', /^ \*= require_self$/, " *= require bootstrap\n *= require base\n *= require_self"
file "app/assets/stylesheets/base.css.scss", <<-CODE
@import "bootstrap";

.navbar .navbar-right {
  padding-top:   7px;
  padding-right: 10px;
  li {
    margin-left: 6px;
  }
  .btn {
    height: 36px;
    line-height: 30px;
    padding: 3px 15px;
  }
  .btn-primary {
    color: white;
  }
  .btn-default:hover {
    color: black;
    background-color: #CCC;
  }
  .btn-primary:hover {
    background-color: #33C;
  }
}

CODE
run 'rm -f app/views/layouts/application.html.erb'
file "app/views/layouts/application.html.erb",
  <<-CODE
<!DOCTYPE html>
<html lang="ja">
  <head>
    <meta charset="UTF-8" />
    <title><%= t 'app_name' %></title>
    <meta name="google" value="notranslate">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
    <%= stylesheet_link_tag    "application", media: "all", "data-turbolinks-track" => true %>
    <%= javascript_include_tag "application", "data-turbolinks-track" => true %>
    <%= csrf_meta_tags %>
  </head>
  <body>
    <%= render file:'layouts/navbar' %>
    <div class="container">
      <%= yield %>
    </div>
  </body>
</html>
CODE
file "app/views/layouts/navbar.html.erb",
  <<-CODE
    <nav class="navbar navbar-inverse navbar-static-top" role="navigation">
      <div class="container-fluid">
        <div class="navbar-header">
          <button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#bs-example-navbar-collapse-1">
            <span class="sr-only">Toggle navigation</span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
          <%= link_to root_path, class:'navbar-brand' do %>
            <%= t 'app_name' %>
          <% end %>
        </div>
        <div class="collapse navbar-collapse">
          <ul class="nav navbar-nav">
            <li class="active"><a href="#">Link</a></li>
            <li><a href="#">Link</a></li>
            <li class="dropdown">
              <a href="#" class="dropdown-toggle" data-toggle="dropdown">Dropdown <b class="caret"></b></a>
              <ul class="dropdown-menu">
                <li><a href="#">Action</a></li>
                <li><a href="#">Another action</a></li>
                <li><a href="#">Something else here</a></li>
                <li class="divider"></li>
                <li><a href="#">Separated link</a></li>
                <li class="divider"></li>
                <li><a href="#">One more separated link</a></li>
              </ul>
            </li>
          </ul>
          <form class="navbar-form navbar-left" role="search">
            <div class="form-group">
              <input type="text" class="form-control" placeholder="Search">
            </div>
            <button type="submit" class="btn btn-default">Submit</button>
          </form>
          <ul class="nav navbar-nav navbar-right">
<%- if defined? Devise -%>
<%-   if user_signed_in? -%>
            <li class="dropdown">
              <a href="#" class="dropdown-toggle btn btn-default" data-toggle="dropdown">
                <span class="glyphicon glyphicon-user"></span>
                Dropdown
                <b class="caret"></b>
              </a>
              <ul class="dropdown-menu">
                <%= content_tag :li do %>
                  <%= link_to edit_user_registration_path do %>
                    <i class="fa fa-cog fa-lg"></i> <%= t 'edit_user_registration' %>
                  <% end %>
                <% end %>
                <li class="divider"></li>
                <%= content_tag :li do %>
                  <%= link_to destroy_user_session_path, method: :delete do %>
                    <i class="fa fa-power-off fa-lg"></i> <%= t 'sign_out' %>
                  <% end %>
                <% end %>
                <li>
                  <a href="#">Separated link</a>
                </li>
              </ul>
            </li>
<%-   else -%>
<%-     unless controller.is_a? Devise::SessionsController -%>
            <%= content_tag :li do %>
              <%= link_to new_user_session_path, class:'btn btn-default' do %>
                <i class="fa fa-sign-in fa-lg"></i> <%= t 'sign_in' %>
              <% end %>
            <% end %>
<%-     end -%>
<%-     unless controller.is_a? Devise::RegistrationsController -%>
            <%= content_tag :li do %>
              <%= link_to new_user_registration_path, class:'btn btn-primary' do %>
                <i class="fa fa-edit fa-lg"></i> <%= t 'sign_up' %>
              <% end %>
            <% end %>
<%-     end -%>
<%-   end -%>
<%- end -%>
          </ul>
        </div>
      </div>
    </nav>
CODE



## Configure font-awesome-sass
gsub_file 'app/assets/stylesheets/application.css',
  /^ \*= require_self$/,
  " *= require font-awesome\n *= require_self"



## Update test frameworks to rspec and cucumber with FactoryGirl.
generate 'rspec:install'
gsub_file 'config/application.rb', /^  end\nend$/, "\n    config.generators do |g|\n      g.test_framework      :rspec\n      g.integration_tool    :rspec\n      g.fixture_replacement :factory_girl, dir:'spec/factories'\n    end\n  end\nend"

#file 'lib/tasks/rspec.rake', <<-CODE
#require 'rspec/core/rake_task'
#RSpec::Core::RakeTask.new(:spec)
#CODE

generate 'cucumber:install'

run 'guard init'


## Generate home page.
generate :controller, 'welcome index'
gsub_file 'config/routes.rb', /# (root 'welcome#index')/, '\1'
gsub_file 'config/routes.rb', /^ +get "welcome\/index"$/, ''


## Configure rails_config
generate 'rails_config:install'



## Configure simple_form
generate 'simple_form:install --bootstrap'
gsub_file 'config/initializers/simple_form.rb',
  /^(\s*config\.button_class = 'btn)'$/,
  '\1 btn-default\''
gsub_file 'config/initializers/simple_form.rb',
  /^(\s*)#\s*(config\.form_class =) .+$/,
  '\1\2 "form-horizontal"'
gsub_file 'config/initializers/simple_form.rb',
  /^(\s*config\.label_class = 'control-label)'$/,
  '\1 col-sm-2\''
gsub_file 'config/initializers/simple_form.rb',
  /^(\s*)#?\s*(config\.error_notification_class =) .+$/,
  '\1\2 \'alert alert-danger\''
gsub_file 'config/initializers/simple_form_bootstrap.rb',
  /^  config.wrappers :bootstrap, .*\n(    .+\n){7}    end\n  end\n/,
  <<-CODE
  config.wrappers :bootstrap, tag: 'div', class: 'form-group', error_class: 'has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label
    b.wrapper tag: 'div', class: 'controls col-sm-10' do |row|
      row.wrapper tag: 'div', class: 'row' do |ba|
        ba.use :input
        ba.use :error, wrap_with: { tag: 'span', class: 'help-block col-sm-4' }
        ba.use :hint,  wrap_with: { tag: 'p', class: 'help-block' }
      end
    end
  end
CODE
gsub_file 'config/initializers/simple_form.rb',
  /^(\s*)#?\s*(config\.input_class =) .+$/,
  '\1\2 \'form-control col-sm-8\''
append_file "app/assets/stylesheets/base.css.scss", <<-CODE
input.form-control{
  width: auto;
};
CODE



## Configure kaminari
generate 'kaminari:config'
generate 'kaminari:views', 'bootstrap'

gsub_file 'app/views/kaminari/_paginator.html.erb',
  /^(\s*<div) .*>$/,
  '\1>'
gsub_file 'app/views/kaminari/_paginator.html.erb',
  /^(\s*<ul)>$/,
  '\1 class="pagination">'



## Configure Devise
generate 'devise:install', '-q'

environment "config.action_mailer.default_url_options = { host: 'localhost:3000' }"

generate 'devise:views'
generate :devise, 'User', 'name:string', 'deleted_at:datetime', 'lock_version:integer'

#insert_into_file "app/views/layouts/application.html.erb", "<%= render partial: 'devise/shared/links', locals: {resource_name: User, devise_mapping:Devise.mappings[:user]} %>\n", after: "<!--/.well -->\n"



## Generate My page
generate :controller, 'my', 'top'
gsub_file 'config/routes.rb', /^ +get "my\/top"$/, '  get "my" => "my#top"'

insert_into_file 'app/controllers/my_controller.rb', "  before_filter :authenticate_user!\n", after: "ApplicationController\n"

insert_into_file 'app/controllers/welcome_controller.rb', "\n\n  private\n\n    def redirect_to_my_top\n      redirect_to my_path if user_signed_in?\n    end\n", after: "  end"
insert_into_file 'app/controllers/welcome_controller.rb', "\n  before_filter :redirect_to_my_top\n\n", before: "  def index"


## Create databases
rake "db:create"


## Configure capistrano
run 'mkdir -p misc/capistrano'

inside('misc/capistrano') do
  run 'capify .'
end

