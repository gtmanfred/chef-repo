template "#{node[:mysql][:confd_dir]}/slave.cnf" do
  source "slave.erb"
  notifies :restart, "service[mysql]"
  variables(
    id => node[:ipaddress].rpartition('.').last
  )
end
