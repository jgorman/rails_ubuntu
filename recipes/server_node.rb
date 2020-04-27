# frozen_string_literal: true

# Set up a Node server.

chef_log("began")
include_recipe "rails_ubuntu::server_basic"
include_recipe "rails_ubuntu::node"
include_recipe "rails_ubuntu::nginx_passenger"
include_recipe "rails_ubuntu::database"
chef_log("ended")
