# frozen_string_literal: true

# Set up a Redis server.

chef_log("began")
include_recipe "rails_ubuntu::server_basic"
include_recipe "rails_ubuntu::redis"
chef_log("ended")
