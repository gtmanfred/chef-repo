current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                'knifeadm'
client_key               '/home/knife/chef-repo/.chef/knifeadm.pem'
validation_client_name   'chef-validator'
validation_key           '/home/knife/chef-repo/.chef/chef-validator.pem'
chef_server_url          'https://daniel-chef.gtmanfred.com:443'
syntax_check_cache_path  '/home/knife/chef-repo/.chef/syntax_check_cache'
cookbook_path            "#{current_dir}/../cookbooks"
