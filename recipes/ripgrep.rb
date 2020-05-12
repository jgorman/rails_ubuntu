# frozen_string_literal: true

# Install ripgrep.
#
# https://github.com/BurntSushi/ripgrep#installation
# https://github.com/BurntSushi/ripgrep/releases
# See the Debian / Ubuntu section to install from the .deb file.

return if skip_recipe
return chef_log('installed') if File.exist?('/usr/bin/rg')

bash 'ripgrep' do
  code <<-BASH
    #{bash_began}

    rg --version >/dev/null 2>&1 || {
      curl -sL https://github.com/BurntSushi/ripgrep/releases/download/11.0.2/ripgrep_11.0.2_amd64.deb -o /tmp/ripgrep_11.0.2_amd64.deb
      dpkg -i /tmp/ripgrep_11.0.2_amd64.deb
      rm /tmp/ripgrep_11.0.2_amd64.deb
    }

    #{bash_ended}
  BASH
end
