# rails_ubuntu CHANGELOG

## v0.1.0

Initial release.

## v0.2.0 - 2020-05-07

There is a Chef Workstation 0.18.3 bug on Ubuntu 20.04.
$HOME is set to /root instead of /home/<deploy_user>.
This release notices the problem and resets $HOME to
<deploy_home> or /home/<deploy_user>.

## v0.2.1 - 2020-05-12

- Some README improvements.
- Bug fixes for the redis and proxysql recipes.
- Add guards around already installed features.
