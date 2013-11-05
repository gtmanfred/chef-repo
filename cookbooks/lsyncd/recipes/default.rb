#
# Cookbook Name:: lsyncd
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

package "lsyncd"

template "/etc/lsyncd.lua" do
  mode 0644
  owner "root"
  group "root"
  variables(
    :slaves => search(:node, 'role:web-slave')
  )
end

