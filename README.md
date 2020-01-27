# rails_ubuntu Chef Cookbook

A Chef cookbook to provision Ubuntu for Rails deployment using Capistrano.

Modeled on the excellent Go Rails deployment guides.
A big shout out to [Chris Oliver](https://gorails.com/users/1)!

- https://gorails.com/deploy/ubuntu/18.04

Tested on Ubuntu 16.04, 18.04 and 20.04 beta.

Here are three steps to a running Ubuntu Rails server.

1. [Add the Deploy User](#deploy-user)
2. [Run Chef to Provision the Server](#chef)
3. [Run Capistrano to Install Rails](#capistrano)

Then you can run `cap deploy` any time to effortlessly update
your Rails applications running on all of your test, staging,
and production servers!

See below for more information.

- Recipe Documentation
- Attribute Defaults
- Chef-Run Setup
- Wrapper Cookbook Setup
- Debugging Hints

# <a id="deploy-user"></a>1. Add the Deploy User #

### 1.1. Deploy User with Passwordless Sudo ###

Any user name will work, such as the default user name `vagrant`
for a Vagrant box.

```
root # adduser vagrant
root # echo "vagrant ALL=(ALL) NOPASSWD: ALL" >/etc/sudoers.d/vagrant
root # su - vagrant
vagrant $ sudo su -
root #
```

### 1.2. Deploy User with Passwordless Ssh ###

Set up passwordless ssh from your workstation user to the deploy user.

Run this on the workstation that you will be deploying your
Rails application from.

```
me@my-mac $ brew install ssh-copy-id
me@my-mac $ ssh-copy-id vagrant@vagrant-box
me@my-mac $ ssh vagrant@vagrant-box
vagrant@vagrant-box $
```

# 2. <a id="chef"></a>Run Chef to Provision the Server #

Use the `chef-run` utility ...

```
my@my-mac $ chef-run --user vagrant --password vagrant vagrant-box \
  mycookbook::setup_vagrant_box
```

See below for some `chef-run` setup hints.

If you see a message like
`dpkg: error: dpkg status database is locked by another process`,
this is Ubuntu running the post-boot automatic package upgrade.
Just wait for this to complete and run the cookbook again.

# 3. <a id="capistrano"></a> Run Capistrano to Install Rails #

Set up your Rails application for deployment with Capistrano.

After your new server is provisioned, run your initial application
deployment using this guide.

https://gorails.com/deploy/ubuntu/18.04#capistrano

```
my@my-mac $ bundle exec cap production deploy --hosts=vagrant-box
```

jj TODO: revisit this after mysql is running:

If `db_name` is set, the `database` recipe will create an
empty production database owned by `db_user`. This is necessary
in order for `db:setup` to work, at least under Postgres.

Because it too dangerous to automate, you must run any new database setup
tasks manually. For example.

```
vagrant@vagrant-box $ cd /home/vagrant/activity_timer/current
vagrant@vagrant-box $ bundle exec bin/rails RAILS_ENV=production db:setup
```


# Recipe Documentation

## `setup_all` - Run all recipes

You can set the `skip_recipes` attribute to skip unnecessary items
or copy this to a new recipe for customization.

## `apt_upgrade` - Upgrade all packages

Start with the latest package versions for security and stability.

## `apt_install` - Apt packages to build ruby

Building a custom ruby gives us control over the exact ruby version and
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

Attributes: `db_type` (postgres | mysql)

Include the postgres or mysql recipe. If `db_type` is not
set, skip database setup.

## `postgres` - Install postgres and create user

Attributes: `db_user`, `db_password`, `db_name`

If `db_user` and `db_password` are set, create the role
with the `createdb` permission.

Capistrano for Postgres fails on db:setup unless the `db_user`
has `createdb` permissions. jj TODO: follow up after mysql works.

If `db_name` is set, create the production database owned by `db_user`.

## `setup_wrapper_example` - Wrapper example

An example of how to wrap and call the `rails_ubuntu` recipes
from another cookbook.

# Attribute Defaults

See `rails_ubuntu/attributes/defaults.rb`

```
default['rails_ubuntu']['server_name']    = node['fqdn']
default['rails_ubuntu']['app_name']       = 'myapp'
# deploy_to = deploy_to || "/home/#{deploy_user}/#{app_name}"

default['rails_ubuntu']['ruby_version']   = '2.6.5'
default['rails_ubuntu']['node_version']   = '12'

default['rails_ubuntu']['deploy_user']    = 'deploy'
default['rails_ubuntu']['deploy_group']   = 'deploy'
# bash_aliases = bash_aliases || [l, la, lc, lt]

# Leave db_type blank to skip database installation.
# db_type = (postgres | mysql)

# Set db_user and db_password to create the user and run db:setup.

# skip_recipes = "bash_aliases, redis"
```

# Debugging Hints

Most of the recipes run bash scripts to install and configure
packages from outside of Ubuntu.

In order to make sense of what is happening and to see
errors the bash scripts all log to `~deploy/chef.log`.

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
