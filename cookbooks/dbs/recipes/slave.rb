dbmasters = search(:node, "master:true")
dbmaster = dbmasters.first
dumpcmds = {}
databases = search(:mysql_dbs, "*:*")
databases.each do |dbs|
  if dbs[:user].nil?
    dbs[:user] = dbs[:id]
  end
  dumpcmds[dbs[:id]] = "-h #{dbmaster[:rackspace][:local_ipv4]} -u #{dbs[:user]} -p#{dbmaster[:dbs][:database][dbs[:user]][:password]} --master-data=1 --flush-privileges #{dbs[:id]}"
end
if dbmasters.size != 1
  Chef::Log.error("#{dbmasters.size} database masters, cannot set up replication!")
else
  template "#{node[:mysql][:confd_dir]}/slave.cnf" do
    source "slave.erb"
    notifies :restart, "service[mysql]"
    variables(
      :id => node[:ipaddress].rpartition('.').last,
      :dbs => databases
    )
  end

  dumpcmds.each do |id, dumpcmd|
    bash "mysql-dump-#{id}" do
      code <<-EOH
        mysqldump #{dumpcmd} | mysql #{id}
        EOH
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
