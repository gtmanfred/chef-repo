#
# Cookbook Name:: lsyncd
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

package "lsyncd"

directory "/etc/lsyncd"

directory "/var/log/lsyncd/"

template "/etc/lsyncd/lsyncd.conf.lua" do
  mode 0644
  owner "root"
  group "root"
  source "lsyncd.lua.erb"
  variables(
    :slaves => search(:node, 'role:web-slave'),
    :location => "/var/www/wordpress"
  )
  notifies :restart, "service[lsyncd]", :delayed
end

cookbook_file "/etc/init/lsyncd.conf" do
  source "lsyncd.init"
  mode "0644"
end

link "/etc/init.d/lsyncd" do
  link_type :symbolic
  to "/lib/init/upstart-job"
end

service "lsyncd" do
  action [:start, :enable, :restart]
end
