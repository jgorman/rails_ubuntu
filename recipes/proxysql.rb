# Install proxysql

# https://proxysql.com/documentation/installing-proxysql/

return if skip_recipe

pv  = node['rails_ubuntu']['proxysql_version']
ssl = node['rails_ubuntu']['proxysql_ssl']
cn  = node['lsb']['codename']

node.default['rails_ubuntu']['bash_aliases']  += <<EOT
alias padmin='mysql -u admin -padmin -h 127.0.0.1 -P 6032 --prompt="Admin> "'
EOT

bash 'proxysql' do
  code <<-EOT
    #{bash_began}

    curl -sS https://repo.proxysql.com/ProxySQL/repo_pub_key | apt-key add -

    echo deb https://repo.proxysql.com/ProxySQL/proxysql-#{pv}.x/#{cn}/ ./ \
      > /etc/apt/sources.list.d/proxysql.list

    apt-get update -qq
    apt-get install -y -qq proxysql mysql-client

    mysql -u admin -padmin -h 127.0.0.1 -P 6032 << EOT2
      update global_variables set variable_value = '#{ssl}'
        where variable_name = 'mysql-have_ssl';
      load mysql variables to runtime;
      save mysql variables to disk;
EOT2

    #{bash_ended}
  EOT
end

service 'proxysql' do
  action [ :enable, :start ]
end
