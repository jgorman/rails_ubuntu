# frozen_string_literal: true

# Set up a Mysql server.

chef_log("began")
include_recipe "rails_ubuntu::server_basic"
include_recipe "rails_ubuntu::mysql"
chef_log("ended")
