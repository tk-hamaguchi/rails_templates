rails_templates
===============

Application templates for Rails4


 
Usage
--------

```
$ rails new {app_name} -T --skip-bundle -m {template_url} 
```

For example...

```
$ rails new my_app -T --skip-bundle -m https://raw.github.com/tk-hamaguchi/rails_templates/master/plain_template.rb
```


Type of templates
--------

|                     | plain_template      | metro_template      |
| ------------------- |:-------------------:|:-------------------:|
| Authentication      | Devise              | Devise              |
| OmniAuth            | none                | none                |
| Form Builder        | SimpleForm          | SimpleForm          |
| Pagenation          | Kaminari            | Kaminari            |
| User Configurator   | RailsConfig         | RailsConfig         |
| Logical deletion    | Paranoia            | Paranoia            |
| Test Solution       | Guard + Spring      | Guard + Spring      |
| Test Frameworks     | RSpec + Cucumber    | RSpec + Cucumber    |
| Test Data Generator | Faker + FactoryGirl | Faker + FactoryGirl |
| Application Server  | Thin or Unicorn     | Thin or Unicorn     |
| Deploy Tools        | Capistrano          | Capistrano          |
| Themes              | none                | TwitterBootstrap    |


License
----------

MIT License
(http://opensource.org/licenses/mit-license.php)


