node.override[:redis][:port] = "6379"
node.override[:redis][:ipaddress] = node[:rackspace][:local_ipv4]
node.save

package "redis-server"

service "redis-server" do
  action [:enable, :start]
end

template "/etc/redis/redis.conf" do
  variables(
    :port => node[:redis][:port],
    :ipaddress => node[:redis][:ipaddress]
  )
  notifies :restart, "service[redis-server]"
end

