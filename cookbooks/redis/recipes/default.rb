#
# Cookbook Name:: redis
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

server = search(:node, "role:redis_server").first

unless server.nil?
  php_pear "redis" do
    preferred_state "beta"
    notifies :restart, "service[apache2]"
  end
  template "#{node[:php][:ext_conf_dir]}/redis.ini" do
    variables(
      :handler => "redis",
      :path => "tcp://#{server.redis.ipaddress}:#{server.redis.port}/"
    )
  end
end
