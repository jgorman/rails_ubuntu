# Install Postgres, create user and database.

return if skip_recipe

db_user     = node['rails_ubuntu']['db_user']
db_password = node['rails_ubuntu']['db_password']
db_name     = node['rails_ubuntu']['db_name']

bash 'postgres_install' do
  code <<-EOT
    #{bash_began('postgres_install')}

    apt-get update -qq
    apt-get install -y -qq postgresql postgresql-contrib libpq-dev

    #{bash_ended('postgres_install')}
  EOT
end

unless db_user && db_password && db_name
  chef_log('skipped user and database creation')
  return
end

bash 'postgres_create_db' do
  code <<-EOT
    #{bash_began('postgres_create_db')}

su - postgres -c psql <<-EOT2
create user "#{db_user}" createdb password '#{db_password}';
create database "#{db_name}" owner '#{db_user}';
EOT2

    #{bash_ended('postgres_create_db')}
  EOT
end
