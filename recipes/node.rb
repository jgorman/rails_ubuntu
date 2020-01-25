# Install node and yarn.

return if skip_recipe

bash "node" do
  code <<-EOT
    #{bash_began}

    curl -sL https://deb.nodesource.com/setup_#{get(:node_version)}.x | bash -

    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
    echo "deb https://dl.yarnpkg.com/debian/ stable main" \
      > /etc/apt/sources.list.d/yarn.list

    apt-get update
    apt-get install -y -qq nodejs yarn

    #{bash_ended}
  EOT
end
