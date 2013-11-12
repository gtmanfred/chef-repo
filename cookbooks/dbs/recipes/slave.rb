include_recipe "mysql::server"

require 'mysql'

dbmasters = search(:node, "master:true")
dbmaster = dbmasters.first
databases = search(:mysql_dbs, "*:*")
master_user = search(:mysql_users, "master_user:true").first
if master_user.nil?
  Chef::Log.error("Please create a master user for all your databases")
end
names = databases.map{ |h| h[:id]}.join(" ")
dumpcmds = "-h #{dbmaster[:rackspace][:local_ipv4]} -u #{master_user[:id]} -p#{master_user[:password]} --master-data=1 --flush-privileges"
if dbmasters.size != 1
  Chef::Log.error("#{dbmasters.size} database masters, cannot set up replication!")
else
  template "#{node[:mysql][:server][:directories][:confd_dir]}/slave.cnf" do
    source "slave.erb"
    notifies :restart, "service[mysql]"
    variables(
      :id => node[:ipaddress].rpartition('.').last,
      :dbs => databases
    )
  end

  bash "mysql-dump" do
    if databases.size == 1
      code <<-EOH
        mysqladmin stop-slave
        mysqldump #{dumpcmds} #{names} | mysql #{names}
        EOH
    else
      code <<-EOH
        mysqladmin stop-slave
        mysqldump #{dumpcmds} --databases #{names} | mysql
        EOH
    end
    not_if do
      m = Mysql.new("localhost", "root", node[:mysql][:server_root_password])
      slave_sql_running = ""
      m.query("show slave status") {|r| r.each_hash {|h| slave_sql_running = h['Slave_SQL_Running'] } }
      slave_sql_running == "Yes"
    end
  end

  ruby_block "start_replication" do
    block do
      Chef::Log.info("Using #{dbmaster.name} as master")
       
      m = Mysql.new("localhost", "root", node[:mysql][:server_root_password])
      command = %Q{
      CHANGE MASTER TO
        MASTER_HOST="#{dbmaster.rackspace.local_ipv4}",
        MASTER_USER="repl",
        MASTER_PASSWORD="#{dbmaster.mysql.server_repl_password}";
      }
      Chef::Log.info "Sending start replication command to mysql: "
      Chef::Log.info "#{command}"
       
      
      m.query("stop slave")
      m.query(command)
      #m.query("start slave")
    end
    not_if do
      m = Mysql.new("localhost", "root", node[:mysql][:server_root_password])
      slave_sql_running = ""
      m.query("show slave status") {|r| r.each_hash {|h| slave_sql_running = h['Slave_SQL_Running'] } }
      slave_sql_running == "Yes"
    end
  end
end
