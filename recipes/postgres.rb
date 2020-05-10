# frozen_string_literal: true

# Install Postgres, create user and database.

return if skip_recipe
return chef_log("installed") if File.exist?("/usr/bin/psql")

db_user     = node["rails_ubuntu"]["db_user"]
db_password = node["rails_ubuntu"]["db_password"]
db_name     = node["rails_ubuntu"]["db_name"]
db_safe     = node["rails_ubuntu"]["db_safe"].to_s =~ /^t/i

bash "postgres_install" do
  code <<~BASH
    #{bash_began("postgres_install")}

    apt-get update -qq
    apt-get install -y -qq postgresql postgresql-contrib libpq-dev

    #{bash_ended("postgres_install")}
  BASH
end

unless db_safe
  bash "postgres_unsafe" do
    code <<~BASH
      #{bash_began("postgres_unsafe")}

      for hba in /etc/postgresql/*/*/pg_hba.conf; do
        grep -q '^host all all all md5' $hba || {
          echo 'host all all all md5' >> $hba
        }
      done

      for pgc in /etc/postgresql/*/*/postgresql.conf; do
        grep -q '^listen_addresses' $pgc || {
          echo "listen_addresses = '*'" >> $pgc
        }
        sed -i -e "s/^listen_addresses.*/listen_addresses = '*'/" $pgc
      done

      systemctl restart postgresql

      #{bash_ended("postgres_unsafe")}
    BASH
  end
end

unless db_user && db_password && db_name
  chef_log("skipped user and database creation")
  return
end

bash "postgres_create_db" do
  code <<~BASH
    #{bash_began("postgres_create_db")}

    su - postgres -c psql <<PSQL
      create user "#{db_user}" createdb password '#{db_password}';
      create database "#{db_name}" owner '#{db_user}';
    PSQL

    #{bash_ended("postgres_create_db")}
  BASH
end
