template "#{node[:mysql][:confd_dir]}/master.cnf" do
  source "master.erb"
  notifies :restart, "service[mysql]"
end
