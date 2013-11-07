name "mysqld"
description "Mysql server with users."
run_list "role[base]", "recipe[mysql::server]", "recipe[mysql::ruby]", "recipe[database::mysql]", "recipe[dbs]"
