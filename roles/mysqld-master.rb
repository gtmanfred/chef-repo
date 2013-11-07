name "mysqld-master"
description "Mysql replication master."
run_list "role[mysqld]", "recipe[dbs::master]", "recipe[mysql::master]"
