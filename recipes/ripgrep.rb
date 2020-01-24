# Install ripgrep.

bash "ripgrep" do
  code <<-EOT
    exec >>~/chef.log 2>&1
    chmod a+w ~/chef.log
    echo -e "===\nLog ripgrep began `date`\n"

    rg --version >/dev/null 2>&1 || {
      curl -sL https://github.com/BurntSushi/ripgrep/releases/download/11.0.2/ripgrep_11.0.2_amd64.deb -o /tmp/ripgrep_11.0.2_amd64.deb
      dpkg -i /tmp/ripgrep_11.0.2_amd64.deb
      rm /tmp/ripgrep_11.0.2_amd64.deb
    }

    echo -e "\nLog ripgrep ended `date`"
  EOT
end
