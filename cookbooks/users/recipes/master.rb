search(:users, '*:*').each do |user_data|
  ruby_block "generate-keypair" do
    block do
      require 'net/ssh'

      dir = File.join(user_data['home'], ".ssh")
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
        File.chown(user_data['uid'], user_data['gid'], dir)
        File.chown(user_data['uid'], user_data['gid'], pub_key)
        File.chown(user_data['uid'], user_data['gid'], private_key)
      end
      node.override[:ssh] = {}
      node.override[:ssh][:public_key] = openssh_format
    end
  end
end
