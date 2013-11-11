dbmasters = search(:node, "mysql_master:true")
dbmaster = dbmasters.first
dumpcmd = "-h #{dbmaster[:rackspace][:local_ipv4]} -u wordpress -p#{dbmaster[:dbs][:database][:wordpress][:password]} --master-data=1 --flush-privileges wordpress"
if dbmasters.size != 1
  Chef::Log.error("#{dbmasters.size} database masters, cannot set up replication!")
else
  template "#{node[:mysql][:confd_dir]}/slave.cnf" do
    source "slave.erb"
    notifies :restart, "service[mysql]"
    variables(
      :id => node[:ipaddress].rpartition('.').last
    )
  end

  bash "mysql_dump" do
    code <<-EOH
      mysqldump #{dumpcmd} | mysql wordpress
      EOH
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
       
      
      puts "Stop slave"
      m.query("stop slave")
      puts "command"
      m.query(command)
      #puts "Start slave"
      #m.query("start slave")
    end
    not_if do
      #TODO this fails if mysql is not running - check first
      m = Mysql.new("localhost", "root", node[:mysql][:server_root_password])
      slave_sql_running = ""
      m.query("show slave status") {|r| r.each_hash {|h| slave_sql_running = h['Slave_SQL_Running'] } }
      slave_sql_running == "Yes"
    end
  end
end
