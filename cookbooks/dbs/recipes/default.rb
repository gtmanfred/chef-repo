include_recipe 'mysql::server'
include_recipe 'database::mysql'

node.override[:dbs][:database][:password] = node[:mysql][:server_root_password]

template "/root/.my.cnf" do
  source "my.cnf.erb"
  owner "root"
  group "root"
  variables(
    :password => node[:mysql][:server_root_password]
  )
end

include_recipe 'dbs::databases'
include_recipe 'dbs::users'
