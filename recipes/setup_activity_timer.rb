# Wrapper example.

node.default['rails_ubuntu']['app_name']      = 'activity-timer'

node.default['rails_ubuntu']['deploy_user']   = 'vagrant'
node.default['rails_ubuntu']['deploy_group']  = 'vagrant'

node.default['rails_ubuntu']['db_type']       = 'postgres'
node.default['rails_ubuntu']['db_user']       = 'vagrant'
node.default['rails_ubuntu']['db_password']   = 'vagrant'

# For example if Capistrano is configured to deploy to
# /home/deploy/activity-timer but we prefer /home/vagrant
# for this test server.
link '/home/deploy' do
  to '/home/vagrant'
end

include_recipe 'rails_ubuntu::setup_all'
#include_recipe 'rails_ubuntu::redis'
#include_recipe 'rails_ubuntu::test_attr'
#include_recipe 'rails_ubuntu::nginx_passenger'
