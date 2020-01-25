# Install postgres and create user.

return if skip_recipe

db_user = get(:db_user) || get(:deploy_user)

bash "postgres" do
  code <<-EOT
    #{bash_began}

    apt-get update
    apt-get install -y -qq postgresql postgresql-contrib libpq-dev

su - postgres -c psql <<-EOT2
create user #{db_user} createdb password '#{get(:db_password)}';
create database #{db_user} owner #{db_user};
EOT2

    #{bash_ended}
  EOT
end
