# frozen_string_literal: true

# Set up a Postgres server.

chef_log("began")
include_recipe "rails_ubuntu::server_basic"
include_recipe "rails_ubuntu::postgres"
chef_log("ended")
