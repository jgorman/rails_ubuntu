# Upgrade packages.
#
# apt-get upgrade can hang while prompting the user for the console encoding.
# https://superuser.com/questions/1332341/console-setup-causes-apt-get-update-to-hang
#

return if skip_recipe

bash 'apt_upgrade' do
  code <<-EOT
    #{bash_began}

    echo 'console-setup console-setup/charmap47 select UTF-8' |
      debconf-set-selections
    export DEBCONF_FRONTEND=noninteractive

    apt-get update -qq
    apt-get upgrade -y -qq

    #{bash_ended}
  EOT
end
