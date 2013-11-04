include_recipe "mysql::server"
include_recipe "database::mysql"

search(:mysql_dbs, '*:*').each do |dbs|
  mysql_database dbs['id'] do
    connection(
      :host => node[:dbs][:database][:host],
      :username => node[:dbs][:database][:username],
      :password => node[:dbs][:database][:password]
    )
    action :create
  end
end

