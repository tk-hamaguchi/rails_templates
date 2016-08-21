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
  gem 'capybara-webkit'
  gem 'database_cleaner'
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
  gem 'faker'
  gem 'faker-japanese'
  gem 'shoulda-matchers'
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
  "production:\n  url: <%= ENV['DATABASE_URL'] %>"


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
append_file 'spec/rails_helper.rb', <<-CODE

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }
CODE
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

generate :devise, 'User', 'username:string', 'deleted_at:datetime:index', 'lock_version:integer'
insert_into_file 'app/models/user.rb',
  "  validates :username,\n    presence: true,\n    length: { in: 2..40 }\n\n" +
    "  validates :email,\n    presence: true,\n    uniqueness: true,\n    email: true\n\n" +
    "  validates :password,\n    presence: true,\n    confirmation: true,\n    length: {minimum: 8, maximum: 120},\n    on: :create\n\n" +
    "  validates :password,\n    confirmation: true,\n    length: {minimum: 8, maximum: 120},\n    on: :update,\n    allow_blank: true\n\n" +
    "  acts_as_paranoid\n\n",
  after: "ApplicationRecord\n"
insert_into_file 'spec/factories/users.rb',
  "    username { Faker::Japanese::Name.name }\n    email { Faker::Internet.email }\n    password 'P@ssw0rd'",
  after: 'factory :user do'

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
= simple_form_for(resource, as: resource_name, url: registration_path(resource_name)) do |f|
  = f.error_notification
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
= simple_form_for(resource, as: resource_name, url: registration_path(resource_name), html: { method: :put }) do |f|
  = f.error_notification
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
= simple_form_for(resource, as: resource_name, url: password_path(resource_name), html: { method: :post }) do |f|
  = f.error_notification
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
= simple_form_for(resource, as: resource_name, url: password_path(resource_name), html: { method: :put }) do |f|
  = f.error_notification
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
  '\1,' + "\n    controllers: {\n      sessions: 'users/sessions',\n" +
    "  registrations: 'users/registrations',\n" +
    "      passwords: 'users/passwords'\n    }\n"


## Generate Home page
generate :controller, :home, :index
insert_into_file 'app/controllers/home_controller.rb',
  "    redirect_to my_top_path if user_signed_in?\n",
  after: "def index\n"
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


run 'cp config/database.yml{,.example}'
run 'cp config/cable.yml{,.example}'
git rm: '--cached config/database.yml'
git rm: '--cached config/cable.yml'


__END__
file 'Dockerfile', <<-"CODE"
FROM ruby

ENV APP_ROOT /myapp
ENV RAILS_ENV production
ENV PORT 3000
ENV DATABASE_URL mysql2://root:mysql123@db/#{app_name}?reconnect=true

RUN apt-get update -qq && apt-get install -y build-essential mysql-client nodejs --no-install-recommends && rm -rf /var/lib/apt/lists/*

RUN mkdir $APP_ROOT
ADD . $APP_ROOT
WORKDIR $APP_ROOT
RUN gem update && gem install bundler --no-ri --no-rdoc
RUN bundle install --deployment --without development test --path vendor/bundle

EXPOSE $PORT

CMD "bundle exec rails s -p $PORT -b '0.0.0.0' -e $RAILS_ENV"
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
    volumes:
      - .:/myapp
    depends_on:
      - db
      - redis
    environment:
      - DATABASE_URL='mysql2://root:mysql123@db/#{app_name}?reconnect=true'
      - SECRET_KEY_BASE=#{SecureRandom.hex(64)}
  web:
    image: nginx
      - app
    ports:
      - '80:80'
      - '443:443'
volumes:

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
