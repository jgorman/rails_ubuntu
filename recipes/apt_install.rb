# Apt packages to build ruby.

return if skip_recipe

bash "apt_install" do
  code <<-EOT
    #{bash_began}

    apt-get update
    apt-get install -y -qq git-core build-essential software-properties-common \
      libcurl4-openssl-dev libffi-dev libreadline-dev libsqlite3-dev \
      libssl-dev libxml2-dev libxslt1-dev libyaml-dev sqlite3 zlib1g-dev \
      vim curl apt-transport-https ca-certificates dirmngr gnupg

    #{bash_ended}
  EOT
end
