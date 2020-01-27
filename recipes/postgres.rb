# Install postgres, create user and database.

return if skip_recipe

db_user     = get(:db_user)
db_password = get(:db_password)
db_name     = get(:db_name)

bash "postgres" do
  code <<-EOT
    #{bash_began}

    apt-get update
    apt-get install -y -qq postgresql postgresql-contrib libpq-dev

    #{bash_ended}
  EOT
end

unless db_user && db_password
  log_msg('skipped user and database creation')
  return
end

bash "db_user" do
  code <<-EOT
    #{bash_began('db_user')}

su - postgres -c psql <<-EOT2
create user #{db_user} createdb password '#{db_password}';
EOT2

    #{bash_ended('db_user')}
  EOT
end

unless db_name
  log_msg('skipped database creation')
  return
end

bash "db_create" do
  code <<-EOT
    #{bash_began('db_create')}

su - postgres -c psql <<-EOT2
create database #{db_name} owner #{db_user};
EOT2

    #{bash_ended('db_create')}
  EOT
end
