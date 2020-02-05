# Install Mysql, create user and database.

return if skip_recipe

db_user     = node['rails_ubuntu']['db_user']
db_password = node['rails_ubuntu']['db_password']
db_name     = node['rails_ubuntu']['db_name']

bash 'mysql_install' do
  code <<-EOT
    #{bash_began('mysql_install')}

    apt-get update -qq
    export DEBIAN_FRONTEND=noninteractive
    apt-get install -y -qq mysql-server mysql-client libmysqlclient-dev

    #{bash_ended('mysql_install')}
  EOT
end

unless db_user && db_password && db_name
  chef_log('skipped user and database creation')
  return
end

bash 'mysql_create_db' do
  code <<-EOT
    #{bash_began('mysql_create_db')}

mysql <<-EOT2
create database if not exists \\`#{db_name}\\`;
create user if not exists \\`#{db_user}\\`@'localhost' identified by '#{db_password}';
create user if not exists \\`#{db_user}\\`@'%' identified by '#{db_password}';
grant all privileges on \\`#{db_name}\\`.* to \\`#{db_user}\\`@'localhost';
grant all privileges on \\`#{db_name}\\`.* to \\`#{db_user}\\`@'%';
flush privileges;
EOT2

    #{bash_ended('mysql_create_db')}
  EOT
end
