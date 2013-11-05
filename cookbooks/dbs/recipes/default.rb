include_recipe 'mysql::server'
include_recipe 'database::mysql'

node.override[:dbs][:database][:password] = node[:mysql][:server_root_password]

include_recipe 'dbs::databases'
include_recipe 'dbs::users'
