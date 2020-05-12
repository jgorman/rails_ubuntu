# frozen_string_literal: true

# Set up a database server.

chef_log('began')
include_recipe 'rails_ubuntu::server_basic'
include_recipe 'rails_ubuntu::database'
chef_log('ended')
