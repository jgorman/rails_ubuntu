default['rails_ubuntu']['server_name']    = node['fqdn']
default['rails_ubuntu']['app_name']       = 'myapp'
# deploy_to = deploy_to || "#{Dir.home}/#{app_name}"

default['rails_ubuntu']['ruby_version']   = '2.6.5'
default['rails_ubuntu']['node_version']   = '12'

default['rails_ubuntu']['deploy_user']    = 'vagrant'
default['rails_ubuntu']['deploy_group']   = 'vagrant'
# bash_aliases = bash_aliases || [l, la, lc, lt]

# Leave db_type blank to skip local database installation.
# db_type = (postgres | mysql)
# Set db_user, db_password and db_name to create
# the empty production database owned by db_user.

# skip_recipes = 'bash_aliases, redis'
