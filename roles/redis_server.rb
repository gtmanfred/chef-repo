name "redis_server"
description "Redis Server Role"
run_list "role[base]", "recipe[redis::server]"
