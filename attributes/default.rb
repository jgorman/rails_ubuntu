default['rails_ubuntu']['server_name']    = node['fqdn']
default['rails_ubuntu']['app_name']       = 'myapp'

default['rails_ubuntu']['ruby_version']   = '2.6.5'
default['rails_ubuntu']['node_version']   = '12'

default['rails_ubuntu']['deploy_user']    = 'vagrant'
default['rails_ubuntu']['deploy_group']   = 'vagrant'
# bash_aliases = bash_aliases || 'l; la; lc; lt;'

# db_type = db_type || 'postgres'  # postgres | mysql
# db_user = db_user || deploy_user
default['rails_ubuntu']['db_password']    = 'vagrant'
