# rails_ubuntu CHANGELOG

## v0.1.0

Initial release.

## v0.1.1

README improvements.

## v0.1.2

README improvements.

## v0.2.0 - 2020-05-07

* README improvements.

* Recipe and attribute improvements.

* Add nginx node templates.

* Add proxysql recipe.

* Add server_\* recipes.

* Improved Kitchen testing.

* Standardize on rubocop-rails_config formatting.

* There is a Chef Workstation 0.18.3 bug on Ubuntu 20.04.
$HOME is set to /root instead of /home/<deploy\_user>.
This release notices the problem and resets $HOME to
<deploy\_home> or /home/<deploy\_user>.

## v0.2.1 - 2020-05-12

* README improvements.
* Better solution for the 20.04 $HOME = /root issue.
* Bug fixes for the redis and proxysql recipes.
* Add guards around already installed features.
