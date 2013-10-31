name "wordpress"
description "Wordpress Single Server Role"
run_list "role[base]", "recipe[apache2]", "recipe[mysql::server]", "recipe[mysql::ruby]", "recipe[php]", "recipe[php::module_mysql]", "recipe[apache2::mod_php5]", "recipe[wordpress]"
