# Install Mysql, create user and database.

return if skip_recipe

db_user     = get(:db_user)
db_password = get(:db_password)
db_name     = get(:db_name)

bash 'mysql' do
  code <<-EOT
    #{bash_began}

    apt-get update -qq
    export DEBIAN_FRONTEND=noninteractive
    apt-get install -y -qq mysql-server mysql-client libmysqlclient-dev

    #{bash_ended}
  EOT
end

unless db_user && db_password && db_name
  log_msg('skipped user and database creation')
  return
end

bash 'db_create' do
  code <<-EOT
    #{bash_began('db_create')}

mysql <<-EOT2
create database if not exists #{db_name};
create user if not exists '#{db_user}'@'localhost' identified by '#{db_password}';
create user if not exists '#{db_user}'@'%' identified by '#{db_password}';
grant all privileges on #{db_name}.* to '#{db_user}'@'localhost';
grant all privileges on #{db_name}.* to '#{db_user}'@'%';
flush privileges;
EOT2

    #{bash_ended('db_create')}
  EOT
end
