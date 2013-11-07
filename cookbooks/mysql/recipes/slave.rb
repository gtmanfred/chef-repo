
## mysql::slave
ruby_block "start_replication" do
  block do
    dbmasters = search(:node, "mysql_master:true")
     
    if dbmasters.size != 1
      Chef::Log.error("#{dbmasters.size} database masters, cannot set up replication!")
    else
      dbmaster = dbmasters.first
      Chef::Log.info("Using #{dbmaster.name} as master")
       
      m = Mysql.new("localhost", "root", node[:mysql][:server_root_password])
      command = %Q{
      CHANGE MASTER TO
        MASTER_HOST="#{dbmaster.rackspace.local_ipv4}",
        MASTER_USER="repl",
        MASTER_PASSWORD="#{dbmaster.mysql.server_repl_password}",
        MASTER_LOG_FILE="#{dbmaster.mysql.master_file}",
        MASTER_LOG_POS=0;
      }
      puts command
      Chef::Log.info "Sending start replication command to mysql: "
      Chef::Log.info "#{command}"
       
      m.query("stop slave")
      m.query(command)
      m.query("start slave")
    end
  end
  not_if do
    #TODO this fails if mysql is not running - check first
    m = Mysql.new("localhost", "root", node[:mysql][:server_root_password])
    slave_sql_running = ""
    m.query("show slave status") {|r| r.each_hash {|h| slave_sql_running = h['Slave_SQL_Running'] } }
    slave_sql_running == "Yes"
  end
end
