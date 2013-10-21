current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                "gtmanfred"
client_key               "#{current_dir}/gtmanfred.pem"
validation_client_name   "gtmanfred-llc-validator"
validation_key           "#{current_dir}/gtmanfred-llc-validator.pem"
chef_server_url          "https://api.opscode.com/organizations/gtmanfred-llc"
cache_type               'BasicFile'
cache_options( :path => "#{ENV['HOME']}/.chef/checksums" )
cookbook_path            ["#{current_dir}/../cookbooks"]
