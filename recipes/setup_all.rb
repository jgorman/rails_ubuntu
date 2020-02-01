# Run all recipes.

chef_log('began')
include_recipe 'rails_ubuntu::bash_aliases'
include_recipe 'rails_ubuntu::apt_upgrade'
include_recipe 'rails_ubuntu::apt_install'
include_recipe 'rails_ubuntu::ripgrep'
include_recipe 'rails_ubuntu::ruby'
include_recipe 'rails_ubuntu::node'
include_recipe 'rails_ubuntu::redis'
include_recipe 'rails_ubuntu::nginx_passenger'
include_recipe 'rails_ubuntu::database'
chef_log('ended')
