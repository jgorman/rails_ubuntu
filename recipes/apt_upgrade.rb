# Upgrade all packages.
#
# apt-get upgrade will hang while prompting the user for the console encoding.
#
# https://superuser.com/questions/1332341/console-setup-causes-apt-get-update-to-hang
#
# We set the console encoding to utf-8 and specify a non interactive upgrade.

bash "apt_upgrade" do
  code <<-EOT
    exec >>~/chef.log 2>&1
    chmod a+w ~/chef.log
    echo -e "===\nLog apt_upgrade began `date`\n"
    echo HOME $HOME

    echo "console-setup console-setup/charmap47 select UTF-8" |
      debconf-set-selections

    export DEBCONF_FRONTEND=noninteractive
    apt-get update && apt-get upgrade -y -qq

    echo -e "\nLog apt_upgrade ended `date`"
  EOT
end
