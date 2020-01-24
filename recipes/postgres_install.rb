# Install postgres.

db_user = get(:db_user) || get(:deploy_user)

bash "postgres_install" do
  code <<-EOT
    exec >>~/chef.log 2>&1
    chmod a+w ~/chef.log
    echo -e "===\nLog postgres_install began `date`\n"

    apt-get update
    apt-get install -y -qq postgresql postgresql-contrib libpq-dev

su - postgres -c psql <<-EOT2
create user #{db_user} createdb password '#{get(:db_password)}';
create database #{db_user} owner #{db_user};
EOT2

    echo -e "\nLog postgres_install ended `date`"
  EOT
end
