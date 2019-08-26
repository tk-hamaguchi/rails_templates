def source_paths
  [Rails.root]
end

database_yml_src = 'config/database.yml'
database_yml_dst = database_yml_src + '.example'
insert_into_file database_yml_src, <<EOT, after: "  encoding: utf8mb4\n"
  collation: utf8mb4_bin
EOT
gsub_file database_yml_src, /^(\s*host:)\s*.+$/, '\1 127.0.0.1'
gsub_file database_yml_src, /^(\s*password:)\s*$/, '\1 mysql123'
gsub_file database_yml_src, /^production:.*$/m, ''
append_to_file database_yml_src, <<EOT
production:
  <<: *default
  url: <%= ENV['DATABASE_URL'] %>
  prepared_statements: true
  reaping_frequency: 0
  checkout_timeout: 15
EOT
remove_file database_yml_dst
copy_file database_yml_src, database_yml_dst


unless File.exist?('docker-compose.development.yml')
  create_file 'docker-compose.development.yml', "version: \"3.7\"\nservices:\n"
end

append_to_file 'docker-compose.development.yml', <<"EOT"
  db:
    image: mysql:8.0.17
    ports:
      - "3306:3306"
    environment:
      MYSQL_ROOT_PASSWORD: mysql123
      MYSQL_DATABASE: #{app_name}
EOT
