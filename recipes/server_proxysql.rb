# frozen_string_literal: true

# Set up a ProxySQL server.

chef_log('began')
include_recipe 'rails_ubuntu::server_basic'
include_recipe 'rails_ubuntu::proxysql'
chef_log('ended')
