ruby_block "generate-keypair" do
  block do
    require 'net/ssh'

    dir = '/root/.ssh'
    pub_key = File.join(dir, 'id_rsa.pub')
    private_key = File.join(dir, 'id_rsa')

    unless Dir.exists?(dir)
      Dir.mkdir(dir, 0700)
    end

    unless File.exists?(private_key)
      key = OpenSSL::PKey::RSA.new 2048

      type = key.ssh_type
      data = [ key.to_blob ].pack('m0')

      openssh_format = "#{type} #{data}"

      File.open(pub_key, 'w') { |file| file.write(openssh_format) }
      File.open(private_key, 'w') { |file| file.write(key) }
    end
    File.chmod(0500, dir)
    File.chmod(0400, pub_key)
    File.chmod(0400, private_key)
    node.override[:ssh] = {}
    node.override[:ssh][:public_key] = File.open(pub_key, 'r').readlines
  end
end

template "/root/.ssh/config" do
  source "ssh-config.erb"
  mode 0400
  owner "root"
  group "root"
  variables(
    :ips => "10.*",
    :config => "~/.ssh/id_rsa"
    )
end

include_recipe "lsyncd"
