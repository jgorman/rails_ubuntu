# rails_ubuntu Chef Cookbook

A Chef cookbook to provision Ubuntu for Rails deployment using Capistrano.

Capistrano is also excellent for running node applications.

Modeled on the excellent Go Rails deployment guides.
A big shout out to [Chris Oliver](https://gorails.com/users/1)!

- https://gorails.com/deploy/ubuntu/18.04

Tested on Ubuntu 16.04 and 18.04 with Postgres and Mysql.

Here are three steps to a running Ubuntu Rails server.

1. [Add the Deploy User](#deploy-user)
2. [Run Chef to Provision the Server](#chef)
3. [Run Capistrano to Install Rails](#capistrano)

Then you can run `cap deploy` any time to effortlessly update
your Rails applications running on all of your test, staging,
and production servers!

See below for more information.

- [Recipe Documentation](#recipes)
- [Attribute Defaults](#attributes)
- [Wrapper Cookbooks](#wrapper-cookbooks)
- [Chef-Run Setup](#chef-run)

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

```
me@my-mac $ chef-run --user vagrant --password vagrant vagrant-box \
  mycookbook::setup_vagrant_box
```

If you see the message
`dpkg: error: dpkg status database is locked by another process`,
this is Ubuntu running the post-boot automatic package upgrade.
Wait for a few minutes for this to complete and try running the cookbook again.

Most of the recipes run bash scripts to install and configure
packages from outside of Ubuntu.

In order to make sense of what is happening and to see
errors the bash scripts all log to `~deploy/chef.log`.

You can watch the provisioning process run on the target server in real time.

```
vagrant@vagrant-box ~ $ touch chef.log
vagrant@vagrant-box ~ $ tail -f chef.log
```

# 3. <a id="capistrano"></a>Run Capistrano to Install Rails #

Set up your Rails application for deployment with Capistrano.

After your new server is provisioned, run your initial application
deployment using this guide.

https://gorails.com/deploy/ubuntu/18.04#capistrano

```
my@my-mac myapp $ bundle exec cap production deploy --hosts=vagrant-box
```

Because it too dangerous to automate, you must run the database setup
tasks manually. For example.

```
vagrant@vagrant-box $ cd /home/vagrant/myapp/current
vagrant@vagrant-box $ bundle exec bin/rails RAILS_ENV=production db:setup
```


# <a id="recipes"></a> Recipe Documentation #

## `setup_all` - Run all recipes ##

You can set the `skip_recipes` attribute to skip unnecessary items
or copy this recipe to a new recipe for customization.

## `apt_upgrade` - Upgrade all packages ##

## `apt_install` - Install build packages ##

## `bash_aliases` - Add bash aliases to the root and deploy users ##

For those of us with muscle memory.

Attributes: `bash_aliases`, `deploy_user`, `deploy_group`

```
# Default aliases:

alias l='ls -l'
alias la='ls -la'
alias lc='ls -C'
alias lt='ls -lrt'
```

## `ripgrep` - Install Ripgrep ##

Useful for figuring out how things are configured
in the application code and in the bundled gems.

```
rg DATABASE_URL
```

## `ruby` - Build Ruby with Rbenv ##

Attributes: `ruby_version`, `deploy_user`, `deploy_group`

## `node` - Install Node and Yarn ##

Attributes: `node_version`

## `redis` - Install Redis service ##

Install Redis for Action Cable websocket support.

## `nginx_passenger` - Install Nginx and Passenger ##

Attributes: `server_name`, `app_name`, `deploy_user`

## `database` - Install Postgres or Mysql and create database ##

Attributes: `db_type` (postgres | mysql)
Attributes: `db_user`, `db_password`, `db_name`

If `db_type` is not set, skip database setup.

Set `db_user`, `db_password` and `db_name` to create
the empty production database owned by `db_user`.

## `postgres` - Install Postgres and create database ##

Can be called directly or by the `database` recipe.

## `mysql` - Install Mysql and create database ##

Can be called directly or by the `database` recipe.

## `setup_wrapper_example` - Wrapper example ##

An example of how to wrap and call the `rails_ubuntu` recipes
from another cookbook.


# <a id="attributes"></a>Attribute Defaults #

See `rails_ubuntu/attributes/defaults.rb`

```
default['rails_ubuntu']['server_name']    = node['fqdn']
default['rails_ubuntu']['app_name']       = 'myapp'
# deploy_to = deploy_to || "/home/#{deploy_user}/#{app_name}"

default['rails_ubuntu']['ruby_version']   = '2.6.5'
default['rails_ubuntu']['node_version']   = '12'

default['rails_ubuntu']['deploy_user']    = 'vagrant'
default['rails_ubuntu']['deploy_group']   = 'vagrant'
# bash_aliases = bash_aliases || [l, la, lc, lt]

# Leave db_type blank to skip local database installation.
# db_type = (postgres | mysql)
# Set db_user, db_password and db_name to create
# the empty production database owned by db_user.

# skip_recipes = 'bash_aliases, redis'
```


# <a id="wrapper-cookbooks"></a>Wrapper Cookbooks #


# <a id="chef-run"></a>Chef-run Setup #

The easiest way to test your wrapper configuration is to use
`chef-run` to Vagrant boxes.

You can spin up a fresh new Vagrant box, provision it,
and deploy your Rails application within minutes. Once that
works for your application you can deploy to a live Ubuntu server.
