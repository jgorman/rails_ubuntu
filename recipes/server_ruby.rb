# frozen_string_literal: true

# Set up a server with rbenv Ruby.

chef_log("began")
include_recipe "rails_ubuntu::server_basic"
include_recipe "rails_ubuntu::ruby"
chef_log("ended")
