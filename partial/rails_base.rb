def source_paths
  [Rails.root]
end

# Copy database.yml to .example and add .gitigrore
database_yml_src = 'config/database.yml'
database_yml_dst = database_yml_src + '.example'
copy_file database_yml_src, database_yml_dst unless File.exist?(database_yml_dst)
append_to_file '.gitignore', database_yml_src
git rm: database_yml_src + ' --cached'

# Set timezone and default locale to application.rb
app_class = app_name.camelize.constantize.const_get(:Application)
insert_into_file 'config/application.rb', <<-'EOT', before: /^  end$/

    config.time_zone = 'Tokyo'
    config.i18n.default_locale = :ja
EOT

# Purge tzinfo-data and merge bcrypt
uncomment_lines 'Gemfile', /gem 'bcrypt'/
comment_lines   'Gemfile', /gem 'tzinfo-data'/

# Add rails-i18n to Gemfile
gem 'rails-i18n'

gsub_file 'config/environments/production.rb', /^(\s*config\.i18n\.fallbacks =)\s*.*$/, '\1 [I18n.default_locale]'
