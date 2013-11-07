#
# Cookbook Name:: hyperdb
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

template "#{node[:wordpress][:dir]}/db-config.php" do
  variables(
    :master => search(:node, 'role:mysqld-master').first,
    :slaves => search(:node, 'role:mysqld-slave')
  )
end

cookbook_file"#{node[:wordpress][:dir]}/wp-content/db.php"
