# frozen_string_literal: true

# Common server set up tasks.

return if skip_recipe

chef_log('began')
include_recipe 'rails_ubuntu::bash_aliases'
include_recipe 'rails_ubuntu::apt_upgrade'
include_recipe 'rails_ubuntu::apt_install'
include_recipe 'rails_ubuntu::tune'
include_recipe 'rails_ubuntu::ripgrep'
chef_log('ended')
