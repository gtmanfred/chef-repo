#
# Cookbook Name:: apache
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

package "apache2"

service "apache2" do
  action    [:start, :enable]
end

execute "a2dissite default" do
  only_if do
    ::File.symlink?("/etc/apache2/sites-enabled/000-default")
  end
  notifies :restart, "service[apache2]"
end

site_name = node['site_name']

document_root = "/var/www/vhosts/#{site_name}"

template "/etc/apache2/sites-available/#{site_name}" do
  source "custom.erb"
  mode 0644
  variables(
    :document_root => document_root,
    :port => 80
  )
  notifies :restart, "service[apache2]"
end

execute "a2ensite #{site_name}" do
  not_if do
    ::File.symlink?("/etc/apache2/sites-enabled/#{site_name}")
  end
  notifies :restart, "service[apache2]"
end

directory document_root do
  owner "root"
  group "wordpress"
  mode 2775
  recursive true
end
