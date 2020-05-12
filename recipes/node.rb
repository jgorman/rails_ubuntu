# frozen_string_literal: true

# Install node and yarn.

return if skip_recipe
return chef_log('installed') if File.exist?('/usr/bin/node')

node_version = node['rails_ubuntu']['node_version']

bash 'node' do
  code <<-BASH
    #{bash_began}

    curl -sL https://deb.nodesource.com/setup_#{node_version}.x | bash -

    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
    echo 'deb https://dl.yarnpkg.com/debian/ stable main' \
      > /etc/apt/sources.list.d/yarn.list

    apt-get update -qq
    apt-get install -y -qq nodejs yarn

    #{bash_ended}
  BASH
end
