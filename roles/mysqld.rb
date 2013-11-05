name "mysqld"
description "Mysql server with users."
run_list "role[base]", "recipe[mysql::server]", "recipe[mysql::ruby]", "recipes[database::mysql]", "recipe[dbs]"
