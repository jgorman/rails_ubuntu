# rails_ubuntu CHANGELOG

## 0.1.0

Initial release.

## 0.2.0 2020-05-07

There is a Chef Workstation 0.18.3 bug on Ubuntu 20.04.
$HOME is set to /root instead of /home/vagrant.

This release works around the bug. See Notes.txt.

Phusion Passenger is not yet released for Ubuntu 20.04.

## 0.2.1 2020-05-09

- Some README improvements.
- Bug fixes for the redis and proxysql recipes.
