name "wordpress"
description "Wordpress Single Server Role"
run_list "role[webserver]", "recipe[wordpress]", "recipe[hyperdb]"
