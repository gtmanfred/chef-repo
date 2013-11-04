#
# Cookbook Name:: dbs
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "mysql::server"
include_recipe "database::mysql"

search(:mysql_users, '*:*').each do |users|
  node.default[:dbs][:database][users['id']] = {}
  node.default[:dbs][:database][users['id']]['user'] = users['id']
  node.default[:dbs][:database][users['id']]['db'] = users['db']
  node.default[:dbs][:database][users['id']]['host'] = users['host']
  if users['password'] == ""
    node.default[:dbs][:database][users['id']][:password] = secure_password
  else
    node.default[:dbs][:database][users['id']][:password] = users['password']
  end
  mysql_database_user users['id'] do
    connection(
      :host => node[:dbs][:database][:host],
      :username => node[:dbs][:database][:username],
      :password => node[:dbs][:database][:password]
    )
    password node[:dbs][:database][users['id']][:password]
    database_name users['db']
    host users['host']
    action [:create, :grant]
  end
end
