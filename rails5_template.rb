#####
##
## Bootstrap template for Rails5
##
## @author @tk_hamaguchi
## @examples Generate with template
##   $ rails new my_app -T --skip-bundle -m https://github.com/tk-hamaguchi/rails_templates/blob/master/bootsttap_template.rb
##
#


## Bootstrap?
bootstrap = yes?('Do you want oto use bootstrap?')

## Create and initialize Git repository.
git :init
git add: '.'
git commit: '-a -m "first commit."'


## Update gem source.
gsub_file 'Gemfile', /^# (gem 'therubyracer'.*)$/, '\1'
gsub_file 'Gemfile', /^# (gem 'bcrypt'.*)$/, '\1'
gsub_file 'Gemfile', /^# (gem 'redis'.*)$/, '\1'


## Add gem files.
gem 'rails-i18n'
gem 'config'
gem 'haml-rails'

gem 'devise'
gem 'devise-i18n'
gem 'simple_form'
gem 'kaminari'
gem 'figaro'
gem 'faker', require: false

if bootstrap
  gem 'bootstrap', '~> 4.0.0.alpha3'
  gem 'font-awesome-rails'
  gem 'rails-assets-tether', '>= 1.1.0', source: 'https://rails-assets.org'
end

gem_group :development, :test do
  gem 'capybara-webkit'
  gem 'database_cleaner'
  gem 'rails-controller-testing', git: 'https://github.com/rails/rails-controller-testing'
  gem 'rspec-rails', '~> 3.5.0'
  gem 'coderay'
  gem 'cucumber-rails', require: false
  gem 'aruba', require: false
  gem 'poltergeist'
  gem 'headless'
  gem 'letter_opener'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'simplecov'
  gem 'simplecov-rcov'
end

gem_group :development do
  gem 'yard', require: false
  gem 'rubocop', require: false
  gem 'rubocop-checkstyle_formatter', require: false
  gem 'brakeman', require: false
  gem 'bullet'
end

## Execute bundle install
run 'bundle install'


## Configure rails.
gsub_file 'config/application.rb', /^# require "rails\/test_unit\/railtie"\n$/, ''

file 'config/initializers/time_zone.rb', <<-CODE
Rails.application.config.time_zone = 'Tokyo'
CODE

file 'config/initializers/i18n.rb', <<-CODE
Rails.application.config.i18n.default_locale = :ja
CODE

file "config/locales/#{app_name}.en.yml", <<-CODE
en:
  app_name: #{app_name.camelize}
  sign_in: Sign in
  sign_up: Sign up
  sign_out: Sign out
  edit_user_registration: Edit Profile
  copyright_html: "Copyright &copy; %{year} #{app_name.camelize} Project, All Rights Reserved."
CODE

file "config/locales/#{app_name}.ja.yml", <<-CODE
ja:
  app_name: #{app_name.camelize}
  sign_in: 'ログイン'
  sign_up: '新規登録'
  sign_out: 'ログアウト'
  edit_user_registration: 'ユーザー設定'
  copyright_html: "Copyright &copy; %{year} #{app_name.camelize} Project, All Rights Reserved."
CODE


## Configure git.
append_file '.gitignore', <<-CODE

*.swp
core
.ruby-gemset.*
.ruby-version.*
.DS_Store
config/database.yml
config/cable.yml
CODE


## Convert to haml
run <<-CODE
rails haml:erb2haml << EOS
y
EOS
CODE


## Configure rails config
generate 'config:install'


## Configure bootstrap-sass
if bootstrap
  insert_into_file 'app/assets/stylesheets/application.css', " *= require bootstrap_custom\n", before: " *= require_tree .\n"

  file 'app/assets/stylesheets/bootstrap_custom.scss', <<-CODE
//$brand-primary: #428bca;
//$navbar-default-color: #777;
//$navbar-default-bg: #f8f8f8;
//$navbar-default-toggle-hover-bg: #ddd;
//$navbar-default-toggle-icon-bar-bg: #888;
//$navbar-default-toggle-border-color: #ddd;
//$navbar-default-link-color: #777;
//$navbar-default-link-hover-color: #333;
//$navbar-default-link-hover-bg: transparent;
//$navbar-default-link-disabled-color: #ccc;
//$navbar-default-link-disabled-bg: transparent;
//$navbar-default-link-active-color: #555;
@import "bootstrap";
  CODE

  ## Configure font-awesome-sass
  insert_into_file 'app/assets/stylesheets/application.css', " *= require font-awesome\n", before: " *= require_tree .\n"

  run 'rm -f app/views/layouts/application.html.haml'
  file 'app/views/layouts/application.html.haml', <<-CODE
!!!
%html{lang:'ja'}
  %head
    %meta{charset:'utf-8'}
    %meta{name:'viewport', content:'width=device-width, initial-scale=1, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no, shrink-to-fit=no'}
    %meta{'http-equiv' => 'x-ua-compatible', 'content' => 'ie=edge'}
    %title
      = t 'app_name'
    = csrf_meta_tags
    = action_cable_meta_tag
    = stylesheet_link_tag    'application', media: 'all', 'data-turbolinks-track' => 'reload'
    = yield :stylesheet_links
  %body
    - unless defined?(header) && header == false
      #header
        = render partial: '/layouts/navbar'
    = content_for?(:content) ? yield(:content) : yield
    = javascript_include_tag 'application', 'data-turbolinks-track' => 'reload'
    = yield :javascript_links
  CODE

  file 'app/views/layouts/_navbar.html.haml', <<-CODE
%nav.navbar.navbar-full.navbar-dark.bg-inverse
  = link_to t('app_name'), root_path, class:'navbar-brand'
  %ul.nav.navbar-nav.pull-xs-right
    %li.nav-item
      .dropdown.pull-xs-right
        - if user_signed_in?
          %a.nav-link.dropdown-toggle#dropdownMenu2{'type' => 'button', 'data-toggle' => 'dropdown', 'aria-haspopup' => true, 'aria-expanded' => false}
            %i.fa.fa-user
            -#= t('grobal-right-dropdown-button')
          .dropdown-menu.dropdown-menu-right{'aria-labelledby' => 'dropdownMenu2'}
            = link_to my_top_path, {class:'dropdown-item', type:'button'} do
              %i.fa.fa-edit
              = t('.edit')
            .dropdown-divider
            = link_to destroy_user_session_path, {class:'dropdown-item', type:'button', method: :delete} do
              %i.fa.fa-power-off
              = t('logout')
        - else
          - unless controller.is_a?(Devise::SessionsController)
            = link_to new_user_session_path, {class:'btn btn-secondary', type:'button'} do
              %i.fa.fa-sign-in
              = t('sign_in')
  CODE

  file 'app/views/layouts/grid_system.html.haml', <<-CODE
- content_for :javascript_links do
  = javascript_include_tag 'grid_system_layout', 'data-turbolinks-track' => 'reload'

= content_for :content do
  .container-fluid
    .row
      .col-sm-12
        #main_contents
          - if notice
            .alert.alert-info#information_area
              = notice
          - if alert
            .alert.alert-danger#warning_area{role:'alert'}
              = alert
          = content_for?(:content) ? yield(:content) : yield
    .row
      .col-sm-12
        = render partial: '/layouts/footer'
  .clearfix
= render template: 'layouts/application'
  CODE

  file 'app/assets/javascripts/grid_system_layout.coffee', <<-CODE
jQuery(document).on 'ready page:load', ->

  $(window).on 'resize', ->
    content_height = $(window).height() - 30 - $('#header').height() - $('#footer').height()
    $('#main_contents').css('min-height', content_height + 'px')

  content_height = $(window).height() - 30 - $('#header').height() - $('#footer').height()
  $('#main_contents').css('min-height', content_height + 'px')
  CODE

  file 'app/views/layouts/home.html.haml', <<-CODE
= render template: 'layouts/grid_system'
  CODE

  file 'app/views/layouts/my.html.haml', <<-CODE
= render template: 'layouts/grid_system'
  CODE

  file 'app/views/layouts/center_middle.html.haml', <<-CODE
= content_for :content do
  .center-middle-layout
    .center-middle-layout-wrapper
      .container
        = content_for?(:content) ? yield(:content) : yield
      .center-middle-layout-footer
        = render partial: '/layouts/footer'
= render template: 'layouts/application', locals:{ header: header }
  CODE

  append_file 'config/initializers/assets.rb', <<-CODE
Rails.application.config.assets.precompile += %w(center_middle_layout.css grid_system_layout.coffee)
  CODE
else
  append_file 'config/initializers/assets.rb', <<-CODE
Rails.application.config.assets.precompile += %w(center_middle_layout.css)
  CODE
end

file 'app/views/layouts/devise.html.haml', <<-CODE
- content_for :stylesheet_links do
  = stylesheet_link_tag 'center_middle_layout', media: 'all', 'data-turbolinks-track' => 'reload'

= render template: 'layouts/center_middle', locals:{ header: true }
CODE


file 'app/assets/stylesheets/center_middle_layout.scss', <<-CODE
.center-middle-layout {
  height: 100%;
  display: table;
  min-height: 100%;
  width: 100%;
  .center-middle-layout-wrapper {
    vertical-align: middle;
    display: table-cell;
    .container {
      margin-right: auto;
      margin-left: auto;
      padding-left: 15px;
      padding-right: 15px;
    }
  }
  .center-middle-layout-footer {
    position: fixed;
    bottom: 0px;
    width: 100%;
    padding: 0px 1rem;
    #footer {
      width: 100%;
    }
  }
}

#header {
  position: fixed;
  top: 0px;
  width: 100%;
}
CODE

#file '', <<-CODE
#CODE

#file '', <<-CODE
#CODE

file 'app/assets/stylesheets/base.css.scss', <<-CODE
html,body {
  height: 100%;
}

body {
  min-width: 320px;
}

#footer {
  width: 100%;
  margin: 0.4rem;
  text-align: center;
  font: {
    size: 0.6rem;
  }
  color: gray
}

.copylight {
  margin: 0px;
}

.version_no {
  float: right;
  margin: 0px;
}
CODE

insert_into_file 'app/assets/stylesheets/application.css', " *= require base\n", before: " *= require_tree .\n"
insert_into_file 'app/assets/javascripts/application.js', "//= require tether\n//= require bootstrap-sprockets\n", before: "//= require_tree .\n"


file "lib/#{app_name}.rb", <<-CODE
require '#{app_name}/version'
CODE

file "lib/#{app_name}/version.rb", <<-CODE
# {app_name.camelize}
module #{app_name.camelize}
  VERSION = '0.1.0'.freeze
end
CODE

file "config/initializers/#{app_name}.rb", <<-CODE
require '#{app_name}'
CODE

file 'app/views/layouts/_footer.html.haml', <<-CODE
#footer
  .version_no
    Ver.
    = #{app_name.camelize}::VERSION
  %address.copylight
    = t 'copyright_html', year: Time.now.year
CODE

gsub_file 'app/assets/stylesheets/application.css',  /^ \*= require_tree \.$/,  ' *  require_tree .'
gsub_file 'app/assets/javascripts/application.js', /^\/\/= require_tree \.$/,  '// require_tree .'


## Update test frameworks to rspec and cucumber with FactoryGirl.
generate 'rspec:install'
generate 'cucumber:install'


## Configure simple_form

if bootstrap
  generate 'simple_form:install --bootstrap'
else
  generate 'simple_form:install'
end
#gsub_file 'config/initializers/simple_form.rb',
#  /^(\s*config\.button_class = 'btn)'$/,
#  '\1 btn-default\''
#gsub_file 'config/initializers/simple_form.rb',
#  /^(\s*)#\s*(config\.form_class =) .+$/,
#  '\1\2 "form-horizontal"'
#gsub_file 'config/initializers/simple_form.rb',
#  /^(\s*config\.label_class = 'control-label)'$/,
#  '\1 col-sm-2\''
#gsub_file 'config/initializers/simple_form.rb',
#  /^(\s*)#?\s*(config\.error_notification_class =) .+$/,
#  '\1\2 \'alert alert-danger\''
#gsub_file 'config/initializers/simple_form_bootstrap.rb',
#  /^  config.wrappers :bootstrap, .*\n(    .+\n){7}    end\n  end\n/,
#  <<-CODE
#  config.wrappers :bootstrap, tag: 'div', class: 'form-group', error_class: 'has-error' do |b|
#    b.use :html5
#    b.use :placeholder
#    b.use :label
#    b.wrapper tag: 'div', class: 'controls col-sm-10' do |row|
#      row.wrapper tag: 'div', class: 'row' do |ba|
#        ba.use :input
#        ba.use :error, wrap_with: { tag: 'span', class: 'help-block col-sm-4' }
#        ba.use :hint,  wrap_with: { tag: 'p', class: 'help-block' }
#      end
#    end
#  end
#CODE
#gsub_file 'config/initializers/simple_form.rb',
#  /^(\s*)#?\s*(config\.input_class =) .+$/,
#  '\1\2 \'form-control col-sm-8\''
#append_file "app/assets/stylesheets/base.css.scss", <<-CODE
#input.form-control{
#  width: auto;
#};
#CODE


## Configure kaminari
generate 'kaminari:config'


#=begin
#generate 'kaminari:views', 'bootstrap'
#
#gsub_file 'app/views/kaminari/_paginator.html.erb',
#  /^(\s*<div) .*>$/,
#  '\1>'
#gsub_file 'app/views/kaminari/_paginator.html.erb',
#  /^(\s*<ul)>$/,
#  '\1 class="pagination">'
#=end


## Configure Devise
generate 'devise:install', '-q'

environment "config.action_mailer.default_url_options = { host: 'localhost:3000' }"

generate :devise, 'User', 'name:string', 'deleted_at:datetime', 'lock_version:integer'
#generate 'devise:views User'


generate :controller, :home, :index
route "root to: 'home#index'"
gsub_file 'config/routes.rb', /^  get 'home\/index'\n$/

### Generate My page
#generate :controller, 'my', 'top'
#gsub_file 'config/routes.rb', /^ +get "my\/top"$/, '  get "my" => "my#top"'
#
#insert_into_file 'app/controllers/my_controller.rb', "  before_filter :authenticate_user!\n", after: "ApplicationController\n"
#
#insert_into_file 'app/controllers/welcome_controller.rb', "\n\n  private\n\n    def redirect_to_my_top\n      redirect_to my_path if user_signed_in?\n    end\n", after: "  end"
#insert_into_file 'app/controllers/welcome_controller.rb', "\n  before_filter :redirect_to_my_top\n\n", before: "  def index"
#

## Create databases
rake 'db:create'


run 'cp config/database.yml{,.example}'
run 'cp config/cable.yml{,.example}'
git rm: '--cached config/database.yml'
git rm: '--cached config/cable.yml'



__END__
file "app/assets/stylesheets/base.css.scss", <<-CODE
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
  run 'cap install STAGES=local,staging,production'
end

gsub_file 'misc/capistrano/Capfile', /# (require 'capistrano\/rvm')/, '\1'
gsub_file 'misc/capistrano/Capfile', /# (require 'capistrano\/bundler')/, '\1'
gsub_file 'misc/capistrano/Capfile', /# (require 'capistrano\/rails\/assets')/, '\1'
gsub_file 'misc/capistrano/Capfile', /# (require 'capistrano\/rails\/migrations')/, '\1'

append_file 'misc/capistrano/Capfile', <<-CODE

require 'capistrano/rails'
require 'capistrano/console'
#require "whenever/capistrano"
CODE

gsub_file 'misc/capistrano/config/deploy.rb', /(set :application,) .*/, "set :application, '#{app_name}'"
gsub_file 'misc/capistrano/config/deploy.rb', /# (ask :branch, .*)/, '\1'
gsub_file 'misc/capistrano/config/deploy.rb', /# (set :deploy_to,) .*/, '\1 "/var/rails/#{fetch(:application)}"'
gsub_file 'misc/capistrano/config/deploy.rb', /# (set :scm,) .*/, '\1 :git'
gsub_file 'misc/capistrano/config/deploy.rb', /# (set :format,) .*/, '\1 :pretty'
gsub_file 'misc/capistrano/config/deploy.rb', /# (set :log_level,) .*/, '\1 :debug'
gsub_file 'misc/capistrano/config/deploy.rb', /# (set :pty,) .*/, '\1 true'
gsub_file 'misc/capistrano/config/deploy.rb', /# (set :linked_files,) .*/, '\1 %w{config/database.yml}'
gsub_file 'misc/capistrano/config/deploy.rb', /# (set :linked_dirs,) .*/, '\1 %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}'
gsub_file 'misc/capistrano/config/deploy.rb', /# (set :keep_releases,) .*/, '\1 5'
append_file 'misc/capistrano/config/deploy.rb', <<-'CODE'

set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }

SSHKit.config.command_map[:rake]     = "bundle exec rake"
SSHKit.config.command_map[:rails]    = "bundle exec rails"
SSHKit.config.command_map[:whenever] = "bundle exec whenever"

set :rvm_type,         :system
set :rvm_ruby_version, "ruby-2.1.2@#{fetch(:application)}"

set :db_name, fetch(:application)
set :db_user, 'root'

set :ssh_options, {
  keys: [File.expand_path('~/.ssh/id_rsa')],
  forward_agent: true,
  auth_methods: %w(publickey)
}

CODE

file "misc/capistrano/lib/capistrano/tasks/#{app_name}.rake", <<-'CODE'
namespace :deploy do

  desc 'upload database.yml'
  task :upload do
    on roles(:app) do |host|
      unless test "[ -f #{shared_path}/config/database.yml ]"
        require 'erb'
        html = ERB.new(File.read("templates/database.yml.erb")).result(binding)
        upload!(StringIO.new(html), "#{shared_path}/config/database.yml")
      end
    end
  end

  desc 'add permission'
  task :add_permission do
    on roles(:app) do |host|
      execute "chmod g+w -R #{release_path}"
      execute "chmod g+w -R #{shared_path}"
    end
  end

  after 'deploy:check:make_linked_dirs', 'deploy:upload'
  after :finishing, 'deploy:cleanup'
  after 'deploy:cleanup', 'deploy:add_permission'


  desc 'upload monit config files'
  task :upload_monitrc do
    on roles(:app) do |host|
      unless test "[ -f #{shared_path}/config/#{fetch(:application)}.monit.rc ]"
        require 'erb'
        html = ERB.new(File.read("templates/monit.rc.erb")).result(binding)
        upload!(StringIO.new(html), "#{shared_path}/config/#{fetch(:application)}.monit.rc")
      end
    end
  end

  desc 'upload nginx config files'
  task :upload_nginx_config do
    on roles(:app) do |host|
      unless test "[ -f #{shared_path}/config/#{fetch(:application)}.nginx.conf ]"
        require 'erb'
        html = ERB.new(File.read("templates/nginx.conf.erb")).result(binding)
        upload!(StringIO.new(html), "#{shared_path}/config/#{fetch(:application)}.nginx.conf")
      end
    end
  end

  desc 'restart puma'
  task :restart_puma do
    on roles(:app) do |host|
      execute "kill -USR2 `cat #{current_path}/tmp/pids/puma.pid`"
    end
  end


  after 'deploy:finishing',           'deploy:upload_monitrc'
  after 'deploy:upload_monitrc',      'deploy:upload_nginx_config'
  #after 'deploy:upload_nginx_config', 'deploy:restart_puma'

end
CODE

run 'mkdir -p misc/capistrano/templates/'


file "misc/capistrano/templates/database.yml.erb", <<-'CODE'
development: &defaults
  adapter: mysql2
  encoding: utf8
  reconnect: false
  username: <%= fetch(:db_user) || fetch(:application) %>
  password: <%= fetch(:db_pass) || '' %>
  database: <%= fetch(:db_name) || fetch(:application) %>
  socket: <%=   fetch(:db_sock) || '/var/lib/mysql/mysql.sock' %>
  pool: 5

test: &test
  <<: *defaults
  database: <%= fetch(:db_name) || fetch(:application) %>_test

staging:
  <<: *defaults

production:
  <<: *defaults

cucumber:
  <<: *test
CODE

file "misc/capistrano/templates/monit.rc.erb", <<-'CODE'
check process <%= fetch(:application) %> with pidfile <%= current_path %>/tmp/pids/puma.pid
  group railsapp
  start program = "/usr/local/rvm/bin/rvm-shell <%= fetch(:rvm_ruby_version) %> -c 'cd <%= current_path %> ; RAILS_ENV=production bundle exec puma -C config/puma.rb -b unix:///var/lib/puma/<%= fetch(:application) %>.sock'" as uid rails and gid rails
  stop program = "/bin/kill `cat <%= current_path %>/tmp/pids/puma.pid`" as uid rails and gid rails
  if failed unixsocket /var/lib/puma/<%= fetch(:application) %>.sock then restart
  if 5 restarts within 5 cycles then timeout
  depends on <%= fetch(:application) %>_database_yml

check file <%= fetch(:application) %>_database_yml path <%= current_path %>/config/database.yml
  group railsapp
  if failed checksum then unmonitor

CODE

file "misc/capistrano/templates/nginx.conf.erb", <<-'CODE'
server{
  listen       80;
  server_name _;
  location / {
    rewrite ^(.*) https://$http_host$1;
    break;
  }
}


server{
  listen 443;
  server_name _;

  root <%= current_path %>/public/;

  client_max_body_size 100M;


  ssl on;
  ssl_certificate     server.crt;
  ssl_certificate_key server.key;

  ssl_session_timeout 5m;

  ssl_protocols       SSLv3 TLSv1;
  ssl_ciphers         HIGH:!ADH:!aNULL:!MD5;

  ssl_prefer_server_ciphers   on;

  location /assets/ {
    root <%= current_path %>/public/;
  }

  location /system/ {
    root <%= current_path %>/public/;
  }

  location /favicon.ico {
    root <%= current_path %>/public/;
  }


  location / {
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_redirect off;
    proxy_read_timeout 300;

    proxy_pass http://<%= fetch(:application) %>;
  }
}
upstream <%= fetch(:application) %> {
  server unix:///var/lib/puma/<%= fetch(:application) %>.sock;
}
CODE

