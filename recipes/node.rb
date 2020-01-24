# Install node and yarn.

bash "node" do
  code <<-EOT
    exec >>~/chef.log 2>&1
    chmod a+w ~/chef.log
    echo -e "===\nLog node began `date`\n"

    curl -sL https://deb.nodesource.com/setup_#{get(:node_version)}.x | bash -

    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
    echo "deb https://dl.yarnpkg.com/debian/ stable main" \
      > /etc/apt/sources.list.d/yarn.list

    apt-get update
    apt-get install -y -qq nodejs yarn

    echo -e "\nLog node ended `date`"
  EOT
end
