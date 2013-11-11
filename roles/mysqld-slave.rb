name "mysqld-slave"
description "Mysql replication slave."
run_list "role[mysqld]", "recipe[dbs::slave]"
