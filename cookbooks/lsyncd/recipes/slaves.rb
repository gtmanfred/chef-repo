template "/root/.ssh/authorized_keys" do
  owner "root"
  group "root"
  mode  0400
  source "auth_keys.erb"
  variables(
    :pub_key => search(:node, "role:web-master")[0][:ssh][:public_key][0]
  )
end
