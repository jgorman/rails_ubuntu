# Set up a Node server.

chef_log('began')
include_recipe 'rails_ubuntu::server_basic'
include_recipe 'rails_ubuntu::node'
chef_log('ended')
