# Upgrade all packages.
#
# apt-get upgrade will hang while prompting the user for the console encoding.
#
# https://superuser.com/questions/1332341/console-setup-causes-apt-get-update-to-hang
#
# We set the console encoding to utf-8 and specify a non interactive upgrade.

return if skip_recipe

bash "apt_upgrade" do
  code <<-EOT
    #{bash_began}

    echo "console-setup console-setup/charmap47 select UTF-8" |
      debconf-set-selections

    export DEBCONF_FRONTEND=noninteractive
    apt-get update -qq
    apt-get upgrade -y -qq

    #{bash_ended}
  EOT
end
