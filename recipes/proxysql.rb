# Install proxysql

return if skip_recipe

pv  = node['rails_ubuntu']['proxysql_version']
cn  = node['lsb']['codename']

bash 'proxysql' do
  code <<-EOT
    #{bash_began}

    curl -sS https://repo.proxysql.com/ProxySQL/repo_pub_key | apt-key add -

    echo deb https://repo.proxysql.com/ProxySQL/proxysql-#{pv}.x/#{cn}/ ./ \
      > /etc/apt/sources.list.d/proxysql.list

    apt-get update -qq
    apt-get install -y -qq proxysql mysql-client

    #{bash_ended}
  EOT
end

service 'proxysql' do
  action [ :enable, :start ]
end
