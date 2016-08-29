#####
##
## Rails5 template
##
## @author @tk_hamaguchi
## @examples Generate with template
##   $ rails new my_app -T --skip-bundle -m https://github.com/tk-hamaguchi/rails_templates/blob/master/rails5_template.rb
##
#


## Bootstrap?
bootstrap = yes?('Do you want oto use bootstrap?')

## Create and initialize Git repository.
git :init
git add: '.'
git commit: '-a -m "first commit."'

email = `git config --get user.email`.strip


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
gem 'email_validator'
gem 'simple_form'
gem 'kaminari'
gem 'figaro'

gem 'paranoia', '>= 2.2.0.pre'
  #github: 'rubysherpas/paranoia', branch: 'rails5'

if bootstrap
  gem 'bootstrap', '~> 4.0.0.alpha3'
  gem 'font-awesome-rails'
  gem 'rails-assets-tether', '>= 1.1.0', source: 'https://rails-assets.org'
end

gem_group :development, :test do
  gem 'pry-byebug'

  gem 'timecop'

  gem 'rspec-rails', '~> 3.5.0'
  gem 'rails-controller-testing', require: false
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'faker-japanese'
  gem 'shoulda-matchers'
  gem 'simplecov'
  gem 'simplecov-rcov'

  gem 'coderay'

  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'aruba', require: false
  gem 'poltergeist'
  gem 'letter_opener'
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
gsub_file 'config/application.rb', /"/, "'"

gsub_file 'config/environments/production.rb', /"(RAILS_LOG_TO_STDOUT)"/, '\'\1\''
gsub_file 'config/environments/production.rb', /config.log_tags = \[ :request_id \]/, 'config.log_tags = [:request_id]'

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
  edit_user_registration: 'ユーザ設定'
  copyright_html: "Copyright &copy; %{year} #{app_name.camelize} Project, All Rights Reserved."

  activerecord:
    attributes:
      user:
        current_password: '現在のパスワード'
        username: 'ユーザ名'
        email: 'メールアドレス'
        password: 'パスワード'
        password_confirmation: '確認用パスワード'
        remember_me: 'ログインを記憶'
        reset_password_token:
        unlock_token:
    models:
      user: 'ユーザ'
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
coverage
CODE

run 'figaro install'

## Convert to haml
run <<-CODE
rails haml:erb2haml << EOS
y
EOS
CODE


## Configure rails config
generate 'config:install'

gsub_file 'config/database.yml',
  /^production:.*/m,
  "production:\n  url: <%= ENV['DATABASE_URL'] %>\n"


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
          %a.nav-link.dropdown-toggle#dropdownMenu2{'data-toggle' => 'dropdown', 'aria-haspopup' => true, 'aria-expanded' => false}
            %i.fa.fa-user
            = current_user.username
          .dropdown-menu.dropdown-menu-right{'aria-labelledby' => 'dropdownMenu2'}
            = link_to edit_user_registration_path, {class:'dropdown-item'} do
              %i.fa.fa-edit
              = t('edit_user_registration')
            .dropdown-divider
            = link_to destroy_user_session_path, {class:'dropdown-item', method: :delete} do
              %i.fa.fa-power-off
              = t('sign_out')
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
          = content_for?(:content) ? yield(:content) : yield
    .row
      .col-sm-12
        = render partial: '/layouts/footer'
  .clearfix
= render template: 'layouts/application'
  CODE

  file 'app/assets/javascripts/grid_system_layout.coffee', <<-'CODE'
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

file 'app/views/layouts/users/registrations.html.haml', <<-CODE
= render template: 'layouts/grid_system'
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

insert_into_file 'app/assets/stylesheets/application.css',
  " *= require base\n",
  before: " *= require_tree .\n"
insert_into_file 'app/assets/javascripts/application.js',
  "//= require tether\n//= require bootstrap-sprockets\n",
  before: "//= require_tree .\n"

file "lib/#{app_name}.rb", <<-CODE
require '#{app_name}/version'
CODE

file "lib/#{app_name}/version.rb", <<-CODE
# {app_name.camelize}
module #{app_name.camelize}
  # VERSION
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

gsub_file 'app/assets/stylesheets/application.css',
  /^ \*= require_tree \.$/,
  ' *  require_tree .'
gsub_file 'app/assets/javascripts/application.js',
  /^\/\/= require_tree \.$/,
  '// require_tree .'


## Update test frameworks to rspec and cucumber with FactoryGirl.
generate 'rspec:install'
gsub_file 'spec/rails_helper.rb',
  /^\#\ (Dir\[Rails\.root\.join\('spec\/support\/\*\*\/\*\.rb'\)\]\.each\ \{\ \|f\|\ require\ f\ \})$/,
  '\1'
file 'spec/support/shoulda_matchers.rb', <<-CODE
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
CODE
file 'spec/support/devise.rb', <<-CODE
RSpec.configure do |config|
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::ControllerHelpers, type: :helper
  config.include Devise::Test::ControllerHelpers, type: :view
end
CODE
file 'spec/support/rails-controller-testing.rb', <<-CODE
RSpec.configure do |config|
  require 'rails-controller-testing'
  [:controller, :view, :request].each do |type|
    config.include ::Rails::Controller::Testing::TestProcess, :type => type
    config.include ::Rails::Controller::Testing::TemplateAssertions, :type => type
    config.include ::Rails::Controller::Testing::Integration, :type => type
  end
end
CODE
prepend_file 'spec/rails_helper.rb', <<-CODE
require 'simplecov'
require 'simplecov-rcov'
SimpleCov.start 'rails'
SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter

CODE
file 'spec/channels/application_cable/channel_spec.rb', <<-CODE
require 'rails_helper'

RSpec.describe ApplicationCable::Channel do
end
CODE
file 'spec/channels/application_cable/connection_spec.rb', <<-CODE
require 'rails_helper'

RSpec.describe ApplicationCable::Connection do
end
CODE
file 'spec/jobs/application_job_spec.rb', <<-CODE
require 'rails_helper'

RSpec.describe ApplicationJob do
end
CODE
file 'spec/mailers/application_mailer_spec.rb', <<-CODE
require 'rails_helper'

RSpec.describe ApplicationMailer do
end
CODE

generate 'cucumber:install'


## Configure simple_form

if bootstrap
  generate 'simple_form:install --bootstrap'
  gsub_file 'config/initializers/simple_form_bootstrap.rb',
    /^  config.button_class = '.*'$/,
    "  config.button_class = 'btn btn-primary btn-lg btn-block'"
  gsub_file 'config/initializers/simple_form_bootstrap.rb',
    /has-error/,
    'has-danger'
  gsub_file 'config/initializers/simple_form_bootstrap.rb',
    /^(.+:error, wrap_with: { tag: 'span', class: 'help-block)(' })$/,
    '\1 form-control-feedback\2'
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
gsub_file 'config/initializers/devise.rb',
  /^  # config.timeout_in = 30.minutes$/,
  '  config.timeout_in = Rails.env.test? ? 10.seconds : 30.minutes'
gsub_file 'config/initializers/devise.rb',
  /^  # config.remember_for = 2.weeks$/,
  '  config.remember_for = Rails.env.test? ? 30.seconds : 2.weeks'
gsub_file 'config/initializers/devise.rb',
  /^( +)# (config.secret_key = '.+')$/,
  '\1\2'
insert_into_file 'app/helpers/application_helper.rb',
  "  def resource_name\n    :user\n  end\n\n  def resource\n    @resource ||= User.new\n  end\n\n  def devise_mapping\n    @devise_mapping ||= Devise.mappings[:user]\n  end\n",
  before: 'end'

file 'app/views/shared/_alerts.html.haml', <<-'CODE'
- if notice
  .alert.alert-info#information_area
    = notice
- if !resource.errors.empty?
  .alert.alert-danger#warning_area{role:'alert'}
    = devise_error_messages!
- elsif alert
  .alert.alert-danger#warning_area{role:'alert'}
    = alert
CODE
generate :devise, 'User', 'username:string', 'deleted_at:datetime:index', 'lock_version:integer'
insert_into_file 'app/models/user.rb',
  "  validates :username,\n            presence: true,\n            length: { in: 2..40 }\n\n" +
    "  validates :email,\n            presence: true,\n            uniqueness: true,\n            email: true\n\n" +
    "  validates :password,\n            presence: true,\n            confirmation: true,\n            length: { minimum: 8, maximum: 120 },\n            on: :create\n\n" +
    "  validates :password,\n            confirmation: true,\n            length: { minimum: 8, maximum: 120 },\n            on: :update,\n            allow_blank: true\n\n" +
    "  acts_as_paranoid\n\n",
  after: "ApplicationRecord\n"
gsub_file 'app/models/user.rb',
  /(:registerable,)/,
  '\1 :timeoutable,'
insert_into_file 'spec/factories/users.rb',
  "    username { Faker::Japanese::Name.name }\n    email { Faker::Internet.email }\n    password 'P@ssw0rd'",
  after: "factory :user do\n"

gsub_file 'spec/models/user_spec.rb',
  /^.*pending.*$/,
  "  it { is_expected.to validate_presence_of(:username) }\n" +
  "  it { is_expected.to validate_length_of(:username).is_at_least(2).is_at_most(40) }\n\n" +
  "  it { is_expected.to validate_presence_of(:email) }\n" +
  "  it { is_expected.to validate_uniqueness_of(:email).case_insensitive }\n\n" +
  "  it { is_expected.to validate_presence_of(:password) }\n" +
  "  it { is_expected.to validate_confirmation_of(:password) }\n" +
  "  it { is_expected.to validate_length_of(:password).is_at_least(8).is_at_most(120) }\n\n"

generate :controller, 'users/registrations'
gsub_file 'app/controllers/users/registrations_controller.rb',
  /ApplicationController/,
  "Devise::RegistrationsController\n  include Users::RegistrationsHelper\n\n" +
    "  before_action :configure_permitted_parameters"
insert_into_file 'app/helpers/users/registrations_helper.rb',
  "  protected\n\n  def configure_permitted_parameters\n" +
    "    devise_parameter_sanitizer.permit(:sign_up) do |user_params|\n" +
    "      user_params.permit(:username, :email, :password, :password_confirmation)\n" +
    "    end\n  end\n",
  after: "Users::RegistrationsHelper\n"
file 'app/views/users/registrations/new.html.haml',
  <<-'CODE'
%h2
  = t('devise.registrations.new.sign_up')

= render 'shared/alerts'

= simple_form_for(resource, as: resource_name, url: registration_path(resource_name)) do |f|
  .form-inputs
    = f.input :username, autofocus: true
    = f.input :email
    = f.input :password, required: true
    = f.input :password_confirmation, required: true
  .form-actions
    = f.button :submit, t('devise.registrations.new.sign_up')
= render 'devise/shared/links'
CODE
file 'app/views/users/registrations/edit.html.haml',
  <<-'CODE'
%h2
  = t('devise.registrations.edit.title', resource: resource.model_name.human)

= render 'shared/alerts'

= simple_form_for(resource, as: resource_name, url: registration_path(resource_name), html: { method: :put }) do |f|
  .form-inputs
    = f.input :username, autofocus: true
    = f.input :email
    - if devise_mapping.confirmable? && resource.pending_reconfirmation?
      %p
        = t('.currently_waiting_confirmation_for_email', email: resource.unconfirmed_email)
    = f.input :password, autocomplete: 'off', hint: t('devise.registrations.edit.leave_blank_if_you_don_t_want_to_change_it'), required: false
    = f.input :password_confirmation, required: false
    = f.input :current_password, hint: t('devise.registrations.edit.we_need_your_current_password_to_confirm_your_changes'), required: true
  .form-actions
    = f.button :submit, t('devise.registrations.edit.update')

%hr

%h3
  = t('devise.registrations.edit.cancel_my_account')
%p
  = t('devise.registrations.edit.unhappy')
  ?
  = link_to(t('devise.registrations.edit.cancel_my_account'), registration_path(resource_name), data: { confirm: t('devise.registrations.edit.are_you_sure') }, method: :delete)
  \.
= link_to t('devise.shared.links.back'), :back
CODE
insert_into_file 'spec/controllers/users/registrations_controller_spec.rb',
  "  it { is_expected.to be_a_kind_of(Devise::RegistrationsController) }\n\n" +
  "  context 'class' do\n" +
  "    subject { described_class }\n" +
  "    it { is_expected.to be_include(Users::RegistrationsHelper) }\n" +
  "  end",
  before: "\nend"
gsub_file 'spec/helpers/users/registrations_helper_spec.rb',
  /^.*pending.*$/,
  ''

generate :controller, 'users/passwords'
gsub_file 'app/controllers/users/passwords_controller.rb',
  /ApplicationController/,
  "Devise::PasswordsController\n  include Users::PasswordsHelper"
file 'app/views/users/passwords/new.html.haml',
  <<-'CODE'
%h2
  = t('devise.passwords.new.forgot_your_password')

= render 'shared/alerts'

= simple_form_for(resource, as: resource_name, url: password_path(resource_name), html: { method: :post }) do |f|
  .form-inputs
    = f.input :email, autofocus: true
  .form-actions
    = f.button :submit, t('devise.passwords.new.send_me_reset_password_instructions')
= render 'devise/shared/links'
CODE
file 'app/views/users/passwords/edit.html.haml',
  <<-'CODE'
%h2
  = t('devise.passwords.edit.change_your_password')

= render 'shared/alerts'

= simple_form_for(resource, as: resource_name, url: password_path(resource_name), html: { method: :put }) do |f|
  = f.input :reset_password_token, as: :hidden
  = f.full_error :reset_password_token
  .form-inputs
    = f.input :password, label: t('devise.passwords.edit.new_password'), required: true, autofocus: true
    = f.input :password_confirmation, label: t('devise.passwords.edit.confirm_new_password'), required: true
  .form-actions
    = f.button :submit, t('devise.passwords.edit.change_my_password')
= render 'devise/shared/links'
CODE
insert_into_file 'spec/controllers/users/passwords_controller_spec.rb',
  "  it { is_expected.to be_a_kind_of(Devise::PasswordsController) }\n\n" +
  "  context 'class' do\n" +
  "    subject { described_class }\n" +
  "    it { is_expected.to be_include(Users::PasswordsHelper) }\n" +
  "  end",
  before: "\nend"
gsub_file 'spec/helpers/users/passwords_helper_spec.rb',
  /^.*pending.*$/,
  ''

generate :controller, 'users/sessions'
gsub_file 'app/controllers/users/sessions_controller.rb',
  /ApplicationController/,
  "Devise::SessionsController\n  include Users::SessionsHelper"
file 'app/views/users/sessions/new.html.haml',
  <<-'CODE'
%h2
  = t('devise.sessions.new.sign_in')

= render 'shared/alerts'

= simple_form_for(resource, as: resource_name, url: session_path(resource_name)) do |f|
  .form-inputs
    = f.input :email, required: false, autofocus: true
    = f.input :password, required: false
    = f.input :remember_me, as: :boolean if devise_mapping.rememberable?
  .form-actions
    = f.button :submit, t('devise.sessions.new.sign_in')
= render 'devise/shared/links'
CODE
insert_into_file 'spec/controllers/users/sessions_controller_spec.rb',
  "  it { is_expected.to be_a_kind_of(Devise::SessionsController) }\n\n" +
  "  context 'class' do\n" +
  "    subject { described_class }\n" +
  "    it { is_expected.to be_include(Users::SessionsHelper) }\n" +
  "  end",
  before: "\nend"
gsub_file 'spec/helpers/users/sessions_helper_spec.rb',
  /^.*pending.*$/,
  ''


gsub_file 'config/routes.rb',
  /^( +devise_for :users.*),?$/,
  '\1,' + "\n" +
    "             controllers: {\n" +
    "               sessions: 'users/sessions',\n" +
    "               registrations: 'users/registrations',\n" +
    "               passwords: 'users/passwords'\n" +
    "             }\n"


## Generate Home page
generate :controller, :home, :index
insert_into_file 'app/controllers/home_controller.rb',
  "    redirect_to my_top_path if user_signed_in?\n",
  after: "def index\n"
insert_into_file 'app/views/home/index.html.haml',
  "= render 'shared/alerts'\n\n",
  before: '%p '
route "root to: 'home#index'"
gsub_file 'config/routes.rb', /^ +get 'home\/index'\n$/, ''
gsub_file 'spec/controllers/home_controller_spec.rb',
  / +describe .+ +it .+ +end\n +end\n\n/m,
  "  context '#index' do\n" +
  "    subject { get :index ; response } \n" +
  "    it { is_expected.to be_success }\n" +
  "    it { is_expected.to render_template(:index) }\n\n" +
  "    context 'with logined user' do\n" +
  "      before { sign_in FactoryGirl.create(:user) }\n" +
  "      it { is_expected.to be_redirect }\n" +
  "      it { is_expected.to redirect_to(my_top_path) }\n" +
  "    end\n" +
  "  end\n"
gsub_file 'spec/helpers/home_helper_spec.rb',
  /^.*pending.*$/,
  ''
gsub_file 'spec/views/home/index.html.haml_spec.rb',
  /^.*pending.*$/,
  ''


## Generate My page
generate :controller, :my, :top
insert_into_file 'app/controllers/my_controller.rb', "  before_action :authenticate_user!\n\n", after: "ApplicationController\n"
insert_into_file 'app/views/my/top.html.haml',
  "= render 'shared/alerts'\n\n",
  before: '%p '
gsub_file 'config/routes.rb', /^ +get 'my\/top'$/, '  get \'my(.:format)\' => \'my#top\', as: \'my_top\''
gsub_file 'spec/controllers/my_controller_spec.rb',
  / +describe .+ +it .+ +end\n +end\n/m,
  'it { is_expected.to use_before_action(:authenticate_user!) }'
gsub_file 'spec/helpers/my_helper_spec.rb',
  /^.*pending.*$/,
  ''
gsub_file 'spec/views/my/top.html.haml_spec.rb',
  /^.*pending.*$/,
  ''

file 'spec/features/sign_up_spec.rb',
 <<-'CODE'
require 'rails_helper'

RSpec.feature "User's sign up", type: :feature do
  scenario 'Sign up new account' do
    @users_params = FactoryGirl.attributes_for(:user)

    visit new_user_registration_path
    fill_in      'user[username]', with: @users_params[:username]
    fill_in      'user[email]', with: @users_params[:email]
    fill_in      'user[password]', with: @users_params[:password]
    fill_in      'user[password_confirmation]', with: @users_params[:password]
    click_button I18n.t('devise.registrations.new.sign_up')

    expect(page).to have_text(I18n.t('devise.registrations.signed_up'))
    expect(page).to have_text('My#top')
  end
end
CODE

## Create databases
#rake 'db:create'


prepend_file 'app/controllers/application_controller.rb', <<-CODE
# ApplicationController
#
# @since 0.1.0
# @author #{email}
#
CODE
prepend_file 'app/controllers/home_controller.rb', <<-CODE
# HomeController
#
# @since 0.1.0
# @author #{email}
#
CODE
prepend_file 'app/controllers/my_controller.rb', <<-CODE
# MyController
#
# @since 0.1.0
# @author #{email}
#
CODE
prepend_file 'app/controllers/users/passwords_controller.rb', <<-CODE
# Users::PasswordsController
#
# @since 0.1.0
# @author #{email}
#
CODE
prepend_file 'app/controllers/users/registrations_controller.rb', <<-CODE
# Users::RegistrationsController
#
# @since 0.1.0
# @author #{email}
#
CODE
prepend_file 'app/controllers/users/sessions_controller.rb', <<-CODE
# Users::SessionsController
#
# @since 0.1.0
# @author #{email}
#
CODE
prepend_file 'app/helpers/application_helper.rb', <<-CODE
# ApplicationHelper
#
# @since 0.1.0
# @author #{email}
#
CODE
prepend_file 'app/helpers/home_helper.rb', <<-CODE
# HomeHelper
#
# @since 0.1.0
# @author #{email}
#
CODE
prepend_file 'app/helpers/my_helper.rb', <<-CODE
# MyHelper
#
# @since 0.1.0
# @author #{email}
#
CODE
prepend_file 'app/helpers/users/passwords_helper.rb', <<-CODE
# Users::PasswordsHelper
#
# @since 0.1.0
# @author #{email}
#
CODE
prepend_file 'app/helpers/users/registrations_helper.rb', <<-CODE
# Users::RegistrationsHelper
#
# @since 0.1.0
# @author #{email}
#
CODE
prepend_file 'app/helpers/users/sessions_helper.rb', <<-CODE
# Users::SessionsHelper
#
# @since 0.1.0
# @author #{email}
#
CODE
prepend_file 'app/mailers/application_mailer.rb', <<-CODE
# ApplicationMailer
#
# @since 0.1.0
# @author #{email}
#
CODE
prepend_file 'app/models/application_record.rb', <<-CODE
# ApplicationRecord
#
# @since 0.1.0
# @author #{email}
#
CODE
prepend_file 'app/models/user.rb', <<-CODE
# User
#
# @since 0.1.0
# @author #{email}
#
CODE
prepend_file 'config/application.rb', <<-CODE
# Application
#
# @since 0.1.0
# @author #{email}
#
CODE
gsub_file 'config/application.rb', /  class Application < Rails::Application\n/, <<-CODE
  # TemplateSample::Application
  #
  # @since 0.1.0
  # @author #{email}
  #
  class Application < Rails::Application
CODE
prepend_file 'app/channels/application_cable/channel.rb', <<-CODE
# ApplicationCable
#
# @since 0.1.0
# @author #{email}
#
CODE
gsub_file 'app/channels/application_cable/channel.rb',
  /    class Channel < ActionCable::Channel::Base\n/,
  <<-CODE
  # ApplicationCable::Channel
  #
  # @since 0.1.0
  # @author #{email}
  #
  class Channel < ActionCable::Channel::Base
CODE
prepend_file 'app/channels/application_cable/connection.rb', <<-CODE
# ApplicationCable
#
# @since 0.1.0
# @author #{email}
#
CODE
gsub_file 'app/channels/application_cable/connection.rb',
  /  class Connection < ActionCable::Connection::Base\n/,
  <<-CODE
  # ApplicationCable::Connection
  #
  # @since 0.1.0
  # @author #{email}
  #
  class Connection < ActionCable::Connection::Base
CODE
prepend_file 'app/jobs/application_job.rb', <<-CODE
# ApplicationJob
#
# @since 0.1.0
# @author #{email}
#
CODE

file '.rubocop.yml', <<-CODE
AllCops:
  Exclude:
    - 'Gemfile'
    - 'Rakefile'
    - 'db/schema.rb'
    - 'vendor/**/*'
    # for Devise
    - 'config/initializers/devise.rb'
    - 'db/migrate/*_devise_create_users.rb'
    # for SimpleForm
    - 'config/initializers/simple_form.rb'
    # for Puma
    - 'config/puma.rb'
    # for Cucumber
    - 'script/cucumber'
    - 'features/**/*'
    - 'lib/tasks/cucumber.rake'
    # for RSpec
    - 'spec/**/*'

Metrics/LineLength:
  Max: 120

Style/ClassAndModuleChildren:
  Enabled: false
CODE

file 'features/support/database_cleaner.rb', <<-CODE
begin
  require 'database_cleaner'
  require 'database_cleaner/cucumber'

  DatabaseCleaner.strategy = :truncation
rescue NameError
  raise "You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it."
end

Around do |scenario, block|
  DatabaseCleaner.cleaning(&block)
end
CODE
file 'features/support/names.rb', <<-'CODE'
def page_name_to_path(page_name, options = {})
  case page_name
  when 'トップページ'
    root_path
  when 'ログインページ'
    new_user_session_path
  when 'パスワード再設定メール送信ページ'
    new_user_password_path
  when 'パスワード再設定ページ'
    edit_user_password_path
  when 'マイトップページ'
    my_top_path
  else
    raise "Unknown page name '#{page_name}'."
  end
end

def form_name_to_id(form_name)
  case form_name
  when 'パスワード再設定フォーム'
    '#new_user'
  when 'パスワード再設定メール送信フォーム'
    '#new_user'
  when 'ログインフォーム'
    '#new_user'
  else
    raise "Unknown form name '#{form_name}'."
  end
end

def area_name_to_id(area_name)
  case area_name
  when 'インフォメーションエリア'
    '#information_area'
  when 'ワーニングエリア'
    '#warning_area'
  else
    raise "Unknown form name '#{area_name}'."
  end
end

def menu_name_to_id(menu_name)
  case menu_name
  when 'ドロップダウンメニュー'
    '#dropdownMenu2'
  else
    raise "Unknown form name '#{menu_name}'."
  end
end
CODE
file 'features/support/driver.rb', <<-CODE
require 'capybara/poltergeist'
Capybara.default_driver = :poltergeist
CODE
file 'features/step_definitions/web_steps.rb', <<-'CODE'
When(/^"(.*)"を表示する$/)do |page_name|
  visit page_name_to_path(page_name)
end

Then(/スクリーンショットを撮って\"(.+)\"に保存/)do |filename|
  page.save_screenshot "./#{filename}"
end

When(/^"([^"]*)"に下記を入力する:$/) do |form_name, table|
  within(form_name_to_id(form_name)) do
    table.hashes.each do |set|
      i = 0
      begin
        find(set['field'])
      rescue => e
        raise e if i > 3
        i += 1
      end
      fill_in set['field'], with: set['value']
    end
  end
end

Given(/^下記のユーザーが登録されている:$/) do |table|
  table.hashes.each do |user_params|
    User.create!(user_params)
  end
end

Then(/^"([^"]*)"が表示されている$/) do |page_name|
  uri = URI.parse(current_url)
  expect(uri.path).to eq page_name_to_path(page_name)
end

When(/^"([^"]*)"の"([^"]*)"をチェック(する|しない)$/) do |form_name, field_name, check|
  within(form_name_to_id(form_name)) do
    if check == 'する'
      check(field_name)
    else
      uncheck(field_name)
    end
  end
end

When(/^"([^"]+)"をクリックする$/) do |label|
  if label =~ /メニュー$/
    target = menu_name_to_id(label)
    find(target).click
  else
    click_on label
  end
end

Then(/^"([^"]*)"に下記が表示されている:$/) do |area_name, string|
  within(area_name_to_id(area_name)) do
    expect(page).to have_content string
  end
end

Given(/^下記の認証情報でログインする$/) do |table|
  user_param = table.hashes.first
  step '"トップページ"を表示する'
  step '"ログイン"をクリックする'
  step '"ログインフォーム"に下記を入力する:', table(%{
    | field             | value                     |
    | user[email]       | #{user_param['email']}    |
    | user[password]    | #{user_param['password']} |
  })
  step '"ログインフォーム"の"user[remember_me]"をチェックしない'
  step '"ログイン"をクリックする'
  step '"マイトップページ"が表示されている'
end

Given(/^ログアウトする$/) do
  step '"ドロップダウンメニュー"をクリックする'
  step '"ログアウト"をクリックする'
  step '"トップページ"が表示されている'
end

Given(/^ログインの記憶時間が"(\d+)秒"となっている$/) do |sec|
  expect(Devise.remember_for).to eq ActiveSupport::Duration.new(sec.to_i, [[:seconds, sec.to_i]])
end

Given(/^セッションのタイムアウト時間が"(\d+)秒"となっている$/) do |sec|
  expect(Devise.timeout_in).to eq ActiveSupport::Duration.new(sec.to_i, [[:seconds, sec.to_i]])
end

Given(/^ログイン失敗時のロック回数が"(\d+)回"となっている$/) do |num|
  expect(Devise.maximum_attempts).to eq num.to_i
end

When(/^"(\d+)秒"待つ$/) do |sec|
  sleep(sec.to_i)
end

Then(/^下記のメールを受信している:$/) do |table|
  @last_mail ||= ActionMailer::Base.deliveries.last
  table.hashes.each do |mail_params|
    val = @last_mail.send(mail_params['field'].to_sym)
    if val.is_a?(Array)
      expect(val).to include mail_params['value']
    else
      expect(val).to eq mail_params['value']
    end
  end
end

Then(/^メール本文が下記の正規表現にマッチする:$/) do |string|
  @last_mail ||= ActionMailer::Base.deliveries.last
  expect(@last_mail.body.to_s).to match(/^#{string}/)
end

When(/^メールキューを空にする$/) do
  ActionMailer::Base.deliveries.clear
end

When(/^メールに含まれているパスワード再設定用URLを開く$/) do
  @last_mail ||= ActionMailer::Base.deliveries.last
  path = @last_mail.body.to_s.match(/"http.+(\/users\/password\/edit\?reset_password_token.+)"/)[1]
  visit path
end

Then(/^メールキューは空になっている$/) do
  expect(ActionMailer::Base.deliveries.empty?).to be_truthy
end

Then(/^"([^"]*)"の"([^"]*)"がハイライトされ、下記のエラーが表示されている:$/) do |form_name, field_name, message|
  within(form_name_to_id(form_name)) do

  end
end
CODE

file 'features/login.feature', <<-CODE
# language:ja

機能: ログイン／ログアウト

背景:
  前提 下記のユーザーが登録されている:
    | username  | email                | password |
    | Test User | testuser@example.com | testpass |


シナリオ: 管理者はトップページから正しい認証情報を使ってログインすることができる
  もし "トップページ"を表示する
  かつ"ログイン"をクリックする
  ならば "ログインページ"が表示されている
  もし "ログインフォーム"に下記を入力する:
    | field             | value                |
    | user[email]       | testuser@example.com |
    | user[password]    | testpass             |
  かつ "ログインフォーム"の"user[remember_me]"をチェックしない
  かつ "ログイン"をクリックする
  ならば "マイトップページ"が表示されている
  かつ "インフォメーションエリア"に下記が表示されている:
    """
    ログインしました。
    """


シナリオ: 未登録者はトップページから未登録の認証情報を使ってログインすることができない
  もし "トップページ"を表示する
  かつ"ログイン"をクリックする
  ならば "ログインページ"が表示されている
  もし "ログインフォーム"に下記を入力する:
    | field          | value                   |
    | user[email]    | unknownuser@example.com |
    | user[password] | testpass                |
  かつ "ログインフォーム"の"user[remember_me]"をチェックしない
  かつ "ログイン"をクリックする
  ならば "ログインページ"が表示されている
  かつ "ワーニングエリア"に下記が表示されている:
    """
    メールアドレスまたはパスワードが違います。
    """


シナリオ: 管理者はトップページから誤った認証情報を使ってログインすることができない
  もし "トップページ"を表示する
  かつ"ログイン"をクリックする
  ならば "ログインページ"が表示されている
  もし "ログインフォーム"に下記を入力する:
    | field          | value                |
    | user[email]    | testuser@example.com |
    | user[password] | unknown              |
  かつ "ログインフォーム"の"user[remember_me]"をチェックしない
  かつ "ログイン"をクリックする
  ならば "ログインページ"が表示されている
  かつ "ワーニングエリア"に下記が表示されている:
    """
    メールアドレスまたはパスワードが違います。
    """

#ならば スクリーンショットを撮って"screen_shot.png"に保存


シナリオ: 管理者はログイン後にログアウトすることができる
  前提 下記の認証情報でログインする
    | username  | email                | password |
    | Test User | testuser@example.com | testpass |
  もし "ドロップダウンメニュー"をクリックする
  かつ "ログアウト"をクリックする
  ならば "トップページ"が表示されている
  かつ "インフォメーションエリア"に下記が表示されている:
    """
    ログアウトしました。
    """
CODE
file 'features/remember_login_info.feature', <<-CODE
# language:ja

機能: ログイン情報を記憶する

背景:
  前提 下記のユーザーが登録されている:
    | username  | email                | password |
    | Test User | testuser@example.com | testpass |
  かつ セッションのタイムアウト時間が"10秒"となっている
  かつ ログインの記憶時間が"30秒"となっている


シナリオ: 管理者はトップページから正しい認証情報を使ってログイン情報を保存してログインすることができる
  もし "トップページ"を表示する
  かつ"ログイン"をクリックする
  ならば "ログインページ"が表示されている
  もし "ログインフォーム"に下記を入力する:
    | field          | value                |
    | user[email]    | testuser@example.com |
    | user[password] | testpass             |
  かつ "ログインフォーム"の"user[remember_me]"をチェックする
  かつ "ログイン"をクリックする
  ならば "マイトップページ"が表示されている
  もし ログアウトする
  かつ "トップページ"を表示する
  #ならば スクリーンショットを撮って"screen_shot.png"に保存
CODE
file 'features/password_reminder.feature', <<-CODE
# language:ja

機能: パスワード再発行

背景:
  前提 下記のユーザーが登録されている:
    | username  | email                | password |
    | TEST USER | testuser@example.com | testpass |

シナリオ: 管理者はパスワード再設定メールからパスワードを再設定することができる
  前提 メールキューを空にする
  もし "トップページ"を表示する
  かつ "ログイン"をクリックする
  ならば "ログインページ"が表示されている
  もし "パスワードを忘れましたか?"をクリックする
  ならば "パスワード再設定メール送信ページ"が表示されている
  もし "パスワード再設定メール送信フォーム"に下記を入力する:
    | field          | value                |
    | user[email]    | testuser@example.com |
  かつ "パスワードの再設定方法を送信する"をクリックする
  ならば "ログインページ"が表示されている
  かつ "インフォメーションエリア"に下記が表示されている:
    """
    パスワードの再設定について数分以内にメールでご連絡いたします。
    """
  もし メールに含まれているパスワード再設定用URLを開く
  ならば "パスワード再設定ページ"が表示されている
  もし "パスワード再設定メール送信フォーム"に下記を入力する:
    | field                       | value       |
    | user[password]              | newpassword |
    | user[password_confirmation] | newpassword |
  かつ "パスワードを変更する"をクリックする
  ならば "マイトップページ"が表示されている
  もし ログアウトする
  ならば "トップページ"が表示されている
  かつ "ログイン"をクリックする
  ならば "ログインページ"が表示されている
  もし "ログインフォーム"に下記を入力する:
    | field          | value                |
    | user[email]    | testuser@example.com |
    | user[password] | newpassword          |
  かつ "ログインフォーム"の"user[remember_me]"をチェックする
  かつ "ログイン"をクリックする
  ならば "マイトップページ"が表示されている

シナリオ: 管理者がパスワード再設定メール送信フォームに誤ったメールアドレス投入した場合
  前提 メールキューを空にする
  もし "トップページ"を表示する
  かつ "ログイン"をクリックする
  ならば "ログインページ"が表示されている
  もし "パスワードを忘れましたか?"をクリックする
  ならば "パスワード再設定メール送信ページ"が表示されている
  もし "パスワード再設定メール送信フォーム"に下記を入力する:
    | field          | value                |
    | user[email]    | unknown@example.com |
  かつ "パスワードの再設定方法を送信する"をクリックする
  ならば "ワーニングエリア"に下記が表示されている:
    """
    1 件のエラーが発生したため ユーザ は保存されませんでした: メールアドレスは見つかりませんでした。
    """
  かつ メールキューは空になっている
  かつ "パスワード再設定メール送信フォーム"の"メールアドレスフィールド"がハイライトされ、下記のエラーが表示されている:
    """
    は見つかりませんでした。
    """

シナリオ: 管理者がパスワード再設定メール送信フォームにメールアドレス投入せずに送信した場合エラーになる
  前提 メールキューを空にする
  もし "トップページ"を表示する
  かつ "ログイン"をクリックする
  ならば "ログインページ"が表示されている
  もし "パスワードを忘れましたか?"をクリックする
  ならば "パスワード再設定メール送信ページ"が表示されている
  もし "パスワードの再設定方法を送信する"をクリックする
  ならば "ワーニングエリア"に下記が表示されている:
    """
    1 件のエラーが発生したため ユーザ は保存されませんでした: メールアドレスを入力してください
    """
  かつ メールキューは空になっている
  かつ "パスワード再設定メール送信フォーム"の"メールアドレスフィールド"がハイライトされ、下記のエラーが表示されている:
    """
    を入力してください
    """

シナリオ: 管理者はパスワード再設定メールからパスワードを再設定するときに確認入力を誤った場合、エラーが表示される
  前提 メールキューを空にする
  もし "トップページ"を表示する
  かつ "ログイン"をクリックする
  ならば "ログインページ"が表示されている
  もし "パスワードを忘れましたか?"をクリックする
  ならば "パスワード再設定メール送信ページ"が表示されている
  もし "パスワード再設定メール送信フォーム"に下記を入力する:
    | field          | value                |
    | user[email]    | testuser@example.com |
  かつ "パスワードの再設定方法を送信する"をクリックする
  ならば "ログインページ"が表示されている
  かつ "インフォメーションエリア"に下記が表示されている:
    """
    パスワードの再設定について数分以内にメールでご連絡いたします。
    """
  もし メールに含まれているパスワード再設定用URLを開く
  ならば "パスワード再設定ページ"が表示されている
  もし "パスワード再設定メール送信フォーム"に下記を入力する:
    | field                       | value       |
    | user[password]              | newpassword |
    | user[password_confirmation] | hogehoge    |
  かつ "パスワードを変更する"をクリックする
  ならば "ワーニングエリア"に下記が表示されている:
    """
    2 件のエラーが発生したため ユーザ は保存されませんでした: 確認用パスワードとパスワードの入力が一致しません 確認用パスワードとパスワードの入力が一致しません
    """
CODE
file 'features/session_timeout.feature', <<-CODE
# language:ja

機能: セッションのタイムアウト

背景:
  前提 下記のユーザーが登録されている:
    | username  | email                | password |
    | Test User | testuser@example.com | testpass |
  かつ セッションのタイムアウト時間が"10秒"となっている

シナリオ: 管理者はトップページから正しい認証情報を使ってログインし、10秒以上放置すると自動ログアウトしている
  前提 下記の認証情報でログインする
    | email                | password |
    | testuser@example.com | testpass |
  もし "15秒"待つ
  かつ "マイトップページ"を表示する
  ならば "ログインページ"が表示されている
  かつ "ワーニングエリア"に下記が表示されている:
    """
    セッションがタイムアウトしました。もう一度ログインしてください。
    """
CODE

append_file 'Rakefile', <<-'EOS'

default_tasks = []

begin
  require 'rspec/core/rake_task'
  default_tasks << :spec
rescue LoadError
end

begin
  require 'cucumber/rake/task'
  default_tasks << :cucumber
rescue LoadError
end

begin
  require 'yard'
  require 'yard/rake/yardoc_task'
  YARD::Rake::YardocTask.new do |t|
    t.files   = ['app/controllers/**/*.rb','app/helpers/**/*.rb', 'app/mailers/**/*.rb', 'app/models/**/*.rb', 'lib/**/*.rb']
    t.options = []
    t.options << '--debug' << '--verbose' if $trace
  end
  default_tasks << :yard
rescue LoadError
end

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
  default_tasks << :rubocop
rescue LoadError
end

begin
  require 'brakeman'

  desc "Check your code with Brakeman"
  task :brakeman do
    result = Brakeman.run app_path: '.', print_report: true
    exit Brakeman::Warnings_Found_Exit_Code unless result.filtered_warnings.empty?
  end
  default_tasks << :brakeman
rescue LoadError
end

desc 'Generate docs'
task :docs do
  system 'rm -rf docs'
  system 'rspec spec -fh -o docs/rspec/index.html'
  system 'mv coverage docs'
  system 'mkdir -p docs/cucumber/'
  system 'cucumber features -f html -o docs/cucumber/index.html'
  system 'yardoc -o docs/yard'
  system 'rubocop -fh -o docs/rubocop/index.html'
  system 'mkdir docs/brakeman/'
  system 'brakeman -f html -o docs/brakeman/index.html'
end

task default: default_tasks
EOS


run 'cp config/database.yml{,.example}'
run 'cp config/cable.yml{,.example}'
git rm: '--cached config/database.yml'
git rm: '--cached config/cable.yml'


file 'Dockerfile', <<-"CODE"
FROM ruby

ENV APP_ROOT /myapp
ENV RAILS_ENV production
ENV PORT 3000
ENV DATABASE_URL mysql2://root:mysql123@db/template_sample?reconnect=true
ENV TZ JST-9
ENV RAILS_SERVE_STATIC_FILES true
ENV RAILS_LOG_TO_STDOUT true
ENV RAILS_MAX_THREADS 5
ENV WEB_CONCURRENCY 2


RUN apt-get update -qq && apt-get install -y build-essential mysql-client postgresql-client nodejs --no-install-recommends && rm -rf /var/lib/apt/lists/*
RUN gem update && gem install bundler --no-ri --no-rdoc

RUN mkdir $APP_ROOT

WORKDIR $APP_ROOT
COPY Gemfile* ./

RUN bundle install --deployment --without development test

ADD . $APP_ROOT

EXPOSE $PORT

CMD bundle exec rails s -p $PORT -b '0.0.0.0' -e $RAILS_ENV
CODE
file 'docker-compose.yml', <<-"CODE"
version: '2'

services:
  db:
    image: mysql
    expose:
     - '3306'
    environment:
      - MYSQL_ROOT_PASSWORD=mysql123
  redis:
    image: redis
  app:
    build: .
    depends_on:
      - db
      - redis
    ports:
      - '3000:3000'
    environment:
      - DATABASE_URL=mysql2://root:mysql123@db/template_sample?reconnect=true
      - SECRET_KEY_BASE=fbf00688f4993a0ddd3f38c9d9f6dab51bf4b9e82a5f195cad1fe8e6c97def64db8901a0c5140e3e663249c0e09e7632e4b4c69511af2a07db296f6ee7be4271
      - APP_ROOT=/myapp
  web:
    image: nginx
    depends_on:
      - app
    ports:
      - '80:80'
      - '443:443'
CODE

__END__
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
=end
