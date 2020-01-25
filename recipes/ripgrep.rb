# Install ripgrep.
#
# https://github.com/BurntSushi/ripgrep#installation
# https://github.com/BurntSushi/ripgrep/releases
#
# See the Debian / Ubuntu section to install from the .deb file.

return if skip_recipe

bash "ripgrep" do
  code <<-EOT
    #{bash_began}

    rg --version >/dev/null 2>&1 || {
      curl -sL https://github.com/BurntSushi/ripgrep/releases/download/11.0.2/ripgrep_11.0.2_amd64.deb -o /tmp/ripgrep_11.0.2_amd64.deb
      dpkg -i /tmp/ripgrep_11.0.2_amd64.deb
      rm /tmp/ripgrep_11.0.2_amd64.deb
    }
    echo "Say something else."

    #{bash_ended}
  EOT
end
