# frozen_string_literal: true

# Install Mysql, create user and database.

return if skip_recipe
return chef_log("installed") if File.exist?("/usr/bin/mysql")

db_user     = node["rails_ubuntu"]["db_user"]
db_password = node["rails_ubuntu"]["db_password"]
db_name     = node["rails_ubuntu"]["db_name"]
db_safe     = node["rails_ubuntu"]["db_safe"].to_s =~ /^t/i

bash "mysql_install" do
  code <<~BASH
    #{bash_began("mysql_install")}

    apt-get update -qq
    export DEBIAN_FRONTEND=noninteractive
    apt-get install -y -qq mysql-server mysql-client libmysqlclient-dev

    #{bash_ended("mysql_install")}
  BASH
end

unless db_safe
  bash "mysql_unsafe" do
    code <<~BASH
      #{bash_began("mysql_unsafe")}

      myc='/etc/mysql/mysql.conf.d/mysqld.cnf'
      sed -i -e "s/^bind-address.*/bind-address = 0.0.0.0/" $myc
      systemctl restart mysql

      #{bash_ended("mysql_unsafe")}
    BASH
  end
end

unless db_user && db_password && db_name
  chef_log("skipped user and database creation")
  return
end

bash "mysql_create_db" do
  code <<~BASH
    #{bash_began("mysql_create_db")}

mysql <<MYSQL
create database if not exists \\`#{db_name}\\`;
create user if not exists \\`#{db_user}\\`@'localhost' identified by '#{db_password}';
create user if not exists \\`#{db_user}\\`@'%' identified by '#{db_password}';
grant all privileges on \\`#{db_name}\\`.* to \\`#{db_user}\\`@'localhost';
grant all privileges on \\`#{db_name}\\`.* to \\`#{db_user}\\`@'%';
flush privileges;
MYSQL

    #{bash_ended("mysql_create_db")}
  BASH
end
