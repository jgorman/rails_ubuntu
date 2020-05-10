# frozen_string_literal: true

# Install proxysql
# https://proxysql.com/documentation/installing-proxysql/

return if skip_recipe
return chef_log("installed") if File.exist?("/usr/bin/proxysql")

pv  = node["rails_ubuntu"]["proxysql_version"]
ssl = node["rails_ubuntu"]["proxysql_ssl"]
cn  = node["lsb"]["codename"]

# Ubuntu 20.04 focal specific version is not available yet. Using 18.04 bionic.
if cn == "focal"
  cn = "bionic"
end

node.default["rails_ubuntu"]["bash_aliases"]  += <<~BASH
alias padmin='mysql -u admin -padmin -h 127.0.0.1 -P 6032 --prompt="Admin> "'
BASH

bash "install proxysql" do
  code <<~BASH
    #{bash_began}

    curl -sS https://repo.proxysql.com/ProxySQL/repo_pub_key | apt-key add -

    echo deb https://repo.proxysql.com/ProxySQL/proxysql-#{pv}.x/#{cn}/ ./ \
      > /etc/apt/sources.list.d/proxysql.list

    apt-get update -qq
    apt-get install -y -qq proxysql mysql-client

    #{bash_ended}
  BASH
end

service "proxysql" do
  action [ :enable, :start ]
end

chef_sleep "waiting for proxysql to start" do
  seconds 3
end

bash "proxysql set ssl to #{ssl}" do
  code <<~BASH
    #{bash_began}

    mysql -u admin -padmin -h 127.0.0.1 -P 6032 <<MYSQL
      update global_variables set variable_value = '#{ssl}'
        where variable_name = 'mysql-have_ssl';
      load mysql variables to runtime;
      save mysql variables to disk;
    MYSQL

    #{bash_ended}
  BASH
end
