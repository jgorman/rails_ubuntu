# Wrapper example.

node.default['rails_ubuntu']['app_name']    = 'activity-timer'
node.default['rails_ubuntu']['db_user']     = 'rails'
node.default['rails_ubuntu']['db_password'] = 'rails123'

include_recipe 'rails_ubuntu::setup_all'
