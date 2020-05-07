# frozen_string_literal: true

# Upgrade packages.
#
# apt-get upgrade can hang while prompting the user for the console encoding.
# https://superuser.com/questions/1332341/console-setup-causes-apt-get-update-to-hang
#
# No hints worked to make grub* upgrades non-interactive so we skip them here.
#

return if skip_recipe

bash "apt_upgrade" do
  code <<-BASH
    #{bash_began}

    echo 'console-setup console-setup/charmap47 select UTF-8' |
      debconf-set-selections
    export DEBCONF_FRONTEND=noninteractive

    apt-get update -qq

    apt-mark hold grub-common grub-pc grub-pc-bin grub2-common
    apt-get upgrade -y -qq
    apt-mark unhold grub-common grub-pc grub-pc-bin grub2-common

    #{bash_ended}
  BASH
end
