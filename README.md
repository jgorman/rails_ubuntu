# rails_ubuntu

A Chef cookook to provision Ubuntu for Rails deployment using Capistrano.

Modeled on these excellent Go Rails guides.
A big shout out to [Chris Oliver](https://gorails.com/users/1)!

- https://gorails.com/deploy/ubuntu/16.04
- https://gorails.com/deploy/ubuntu/18.04
- https://gorails.com/deploy/ubuntu/20.04

Tested on Ubuntu 16.04, 18.04 and 20.04 beta.

Configures Postgres or Mysql to let Capistrano create the databases.

# Ubuntu Server Preparation

If there is not already an ssh server running, install it.

```
apt install openssh-server
```

If there is not already a deploy user, add. Set up passwordless sudo.

```
adduser deploy
adduser deploy sudo
```

Set up passwordless ssh from your workstation user to the deploy user.

Run this on the workstation that you will be deploying your
Rails application from.

```
brew install ssh-copy-id
ssh-copy-id root@1.2.3.4
ssh-copy-id deploy@1.2.3.4
```

# Recipies

## apt_upgrade - Upgrade all packages

Start with the latest package versions for security and stability.

## apt_install - Apt packages to build ruby

Building a custom ruby gives us control over the exact ruby version.

Capistrano can bundle the required gems while running as the deploy user.

## bash_aliases - Add bash aliases to the root and deploy users

For those of us with muscle memory.

Attributes: bash_aliases, deploy_user, deploy_group

```
# Default aliases:

alias l='ls -l'
alias la='ls -la'
alias lc='ls -C'
alias lt='ls -lrt'
```

## ripgrep - Install ripgrep

Useful for figuring out how things are configured
in the application code and the bundled gems.

Assumes amd64 server.

```
rg DATABASE_PASSWORD
```

## ruby - Build ruby with rbenv

Attributes: ruby_version, deploy_user, deploy_group

## node - Install node and yarn

Attributes: node_version

## redis - Install redis service

Use this for Action Cable websocket support.

## nginx_passenger - Install nginx and passenger

Attributes: server_name, app_name, deploy_user

## database - Install postgres or mysql

Attributes: db_type (postgres | mysql), (db_user || deploy_user), db_password

Defaults to postgres. The mysql installer is not written yet.

## postgres - Install postgres and create user

Attributes: (db_user || deploy_user), db_password

## setup_all - Run all recipies

Copy this to a new recipe for customization.

## setup_activity_timer - Wrapper example


# Attribute defaults.

See `attributes/defaults.rb`

```
default['rails_ubuntu']['server_name']    = node['fqdn']
default['rails_ubuntu']['app_name']       = 'myapp'

default['rails_ubuntu']['ruby_version']   = '2.6.5'
default['rails_ubuntu']['node_version']   = '12'

default['rails_ubuntu']['deploy_user']    = 'vagrant'
default['rails_ubuntu']['deploy_group']   = 'vagrant'
# bash_aliases = bash_aliases || (l, la, lc, lt)

# db_type = db_type || 'postgres' (postgres | mysql)
# db_user = db_user || deploy_user
default['rails_ubuntu']['db_password']    = 'vagrant'
```

# Debugging

All of the bash scripts log to `~deploy/chef.log`

# Chef-run Hints

The best way to test this is to use chef-run to Vagrant boxes.
You can spin up a fresh new Vagrant box, provision it,
and deploy your Rails application within minutes. Once that
works for your application you can deploy to a live Ubuntu server.
