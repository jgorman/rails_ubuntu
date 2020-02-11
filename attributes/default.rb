default['rails_ubuntu']['app_name']       = 'myapp'
default['rails_ubuntu']['app_env']        = 'production'
default['rails_ubuntu']['server_name']    = node['fqdn']

default['rails_ubuntu']['ruby_version']   = '2.6.5'
default['rails_ubuntu']['node_version']   = '12'

default['rails_ubuntu']['deploy_user']    = 'vagrant'
default['rails_ubuntu']['deploy_group']   = 'vagrant'
#default['rails_ubuntu']['deploy_to']     = '/home/<deploy_user>/<app_name>'

default['rails_ubuntu']['db_type']        = 'none'
#default['rails_ubuntu']['db_type']       = 'postgres'
#default['rails_ubuntu']['db_type']       = 'mysql'
#default['rails_ubuntu']['db_user']       = 'rails'
#default['rails_ubuntu']['db_password']   = 'rails123'
#default['rails_ubuntu']['db_unsafe']     = 'unsafe'

#default['rails_ubuntu']['redis_unsafe']  = 'unsafe'
#default['rails_ubuntu']['skip_recipes']  = 'bash_aliases, redis'

default['rails_ubuntu']['bash_aliases']   = <<EOT
alias l='ls -l'
alias la='ls -la'
alias lc='ls -C'
alias lt='ls -lrt'
EOT

default['rails_ubuntu']['apt_install'] =
"git-core build-essential software-properties-common \
 vim curl apt-transport-https ca-certificates dirmngr gnupg"

default['rails_ubuntu']['ruby_libs'] =
"libcurl4-openssl-dev libffi-dev libreadline-dev libsqlite3-dev \
 libssl-dev libxml2-dev libxslt1-dev libyaml-dev sqlite3 zlib1g-dev"
