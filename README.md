# rails_ubuntu

A Chef cookbook to provision Ubuntu for Rails deployment using Capistrano.

Modeled on the excellent Go Rails deployment guides.
A big shout out to [Chris Oliver](https://gorails.com/users/1)!

- https://gorails.com/deploy/ubuntu/18.04

Tested on Ubuntu 16.04, 18.04 and 20.04 beta.

Configures Postgres or Mysql to let Capistrano create the databases.

# Ubuntu Server Preparation

Follow this section of the Go Rails deployment guide. For testing,
a vagrant server is ideal.

https://gorails.com/deploy/ubuntu/18.04#vps

1. If there is not already an ssh server running, install it.

```
apt install openssh-server
```

2. If there is not already a deploy user, add one and
set it up for passwordless sudo using this guide.
Any user name will work, such as user vagrant for
a vagrant box.

See Step 6: Creating a Deploy user.

```
adduser deploy
adduser deploy sudo
```

3. Set up passwordless ssh from your workstation user to the deploy user.

Run this on the workstation that you will be deploying your
Rails application from.

```
brew install ssh-copy-id
ssh-copy-id root@1.2.3.4
ssh-copy-id deploy@1.2.3.4
```

# Rails Application Preparation

Set up your Rails application for deployment with Capistrano.

After your new server is provisioned, run your initial deployment
using this guide.

https://gorails.com/deploy/ubuntu/18.04#capistrano

```
bundle exec cap production deploy
```


# `rails_ubuntu` Recipes

## `apt_upgrade` - Upgrade all packages

Start with the latest package versions for security and stability.

## `apt_install` - Apt packages to build ruby

Building a custom ruby gives us control over the exact ruby version.

Capistrano can bundle the required gems while running as the deploy user.

## `bash_aliases` - Add bash aliases to the root and deploy users

For those of us with muscle memory.

Attributes: `bash_aliases`, `deploy_user`, `deploy_group`

```
# Default aliases:

alias l='ls -l'
alias la='ls -la'
alias lc='ls -C'
alias lt='ls -lrt'
```

## `ripgrep` - Install ripgrep

Useful for figuring out how things are configured
in the application code and in the bundled gems.

```
rg DATABASE_URL
```

## `ruby` - Build ruby with rbenv

Attributes: `ruby_version`, `deploy_user`, `deploy_group`

## `node` - Install node and yarn

Attributes: `node_version`

## `redis` - Install redis service

Use this for Action Cable websocket support.

## `nginx_passenger` - Install nginx and passenger

Attributes: `server_name`, `app_name`, `deploy_user`

## `database` - Install postgres or mysql

Attributes: `db_type` (postgres | mysql), `db_user` || `deploy_user`, `db_password`

If `db_type` is set, install the database server and add the `db_user`.

If `db_user` is not set, use the `deploy_user` setting.

Leave `db_type` blank to skip this step.

The mysql installer is not written yet.

## `postgres` - Install postgres and create user

Attributes: `db_user` || `deploy_user`, `db_password`

This is usually called by the `database` recipe to install
postgres and create the `db_user` postgres role.

If `db_user` is not set, use the `deploy_user` setting.

## `setup_all` - Run all recipes

Copy this to a new recipe for customization.

## `setup_activity_timer` - Wrapper example

You can wrap and call the `rails_ubuntu` recipes from another cookbook.

# Attribute defaults.

See `attributes/defaults.rb`

```
default['rails_ubuntu']['server_name']    = node['fqdn']
default['rails_ubuntu']['app_name']       = 'myapp'

default['rails_ubuntu']['ruby_version']   = '2.6.5'
default['rails_ubuntu']['node_version']   = '12'

default['rails_ubuntu']['deploy_user']    = 'deploy'
default['rails_ubuntu']['deploy_group']   = 'deploy'
# bash_aliases = bash_aliases || [l, la, lc, lt]

# Leave db_type blank to skip database installation.
# db_type = (postgres | mysql)
# db_user = db_user || deploy_user
default['rails_ubuntu']['db_password']    = 'deploy'

# Skip recipes: "bash_aliases, redis"
default['rails_ubuntu']['skip_recipes']   = ''
```

# Debugging

Most of the recipes run bash scripts to install and configure
packages from outside of Ubuntu.

In order to make sense of what is happening and to see
errors the bash scripts log to `~deploy/chef.log`.

You can watch the provisioning process run in real time.

```
touch chef.log
tail -f chef.log
```

# Chef-run Hints

The easiest way to test your wrapper configuration is to use
`chef-run` to Vagrant boxes.

You can spin up a fresh new Vagrant box, provision it,
and deploy your Rails application within minutes. Once that
works for your application you can deploy to a live Ubuntu server.
