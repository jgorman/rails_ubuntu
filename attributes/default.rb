default['rails_ubuntu']['server_name']    = node['fqdn']
default['rails_ubuntu']['app_name']       = 'myapp'
# deploy_to = deploy_to || "/home/#{deploy_user}/#{app_name}"

default['rails_ubuntu']['ruby_version']   = '2.6.5'
default['rails_ubuntu']['node_version']   = '12'

default['rails_ubuntu']['deploy_user']    = 'deploy'
default['rails_ubuntu']['deploy_group']   = 'deploy'
# bash_aliases = bash_aliases || [l, la, lc, lt]

# Leave db_type blank to skip database installation.
# db_type = (postgres | mysql)
# db_user = db_user || deploy_user
default['rails_ubuntu']['db_password']    = 'deploy'

# skip_recipes = "bash_aliases, redis"
