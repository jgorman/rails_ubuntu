# Install apt packages to build ruby.

bash "apt_install" do
  code <<-EOT
    exec >>~/chef.log 2>&1
    chmod a+w ~/chef.log
    echo -e "===\nLog apt_install began `date`\n"

    apt-get update
    apt-get install -y -qq git-core build-essential software-properties-common \
      libcurl4-openssl-dev libffi-dev libreadline-dev libsqlite3-dev \
      libssl-dev libxml2-dev libxslt1-dev libyaml-dev sqlite3 zlib1g-dev \
      vim curl apt-transport-https ca-certificates dirmngr gnupg

    echo -e "\nLog apt_install ended `date`"
  EOT
end
