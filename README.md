# rails_ubuntu Chef Cookbook

A Chef cookbook to provision Ubuntu for Rails deployment using
Nginx, Passenger, and Capistrano.

This is also excellent stack for deploying Node applications.

This cookbook is modeled on the excellent Go Rails deployment guide.
A big shout out to [Chris Oliver](https://gorails.com/users/1)!

- https://gorails.com/deploy/ubuntu/18.04

Tested on Ubuntu 16.04 and 18.04 with Postgres and Mysql.

Here are three steps to a running Ubuntu Rails server.

1. [Add the Deploy User](#deploy-user)
2. [Run Chef to Provision the Server](#chef)
3. [Run Capistrano to Install Rails](#capistrano)

Then you can run `cap production deploy` any time to effortlessly update
your Rails applications running on all of your test, staging,
and production servers!

See below for more information.

- [Recipe Documentation](#recipes)
- [Attribute Defaults](#attributes)
- [Wrapper Cookbooks](#wrapper-cookbooks)
- [Chef-Run Setup](#chef-run)
- [Vagrant Setup](#vagrant)

# <a id="deploy-user"></a>1. Add the Deploy User #

These instructions are for setting up the deploy user for a live server.
See the section below for [Vagrant setup](#vagrant).

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
me@mymac $ brew install ssh-copy-id
me@mymac $ ssh-copy-id vagrant@vagrant-box
vagrant@vagrant-box's password:
Number of key(s) added:        1

me@mymac $ ssh vagrant@vagrant-box
vagrant@vagrant-box $
```

# 2. <a id="chef"></a>Run Chef to Provision the Server #

Here is an example of using a [wrapper cookbook](#wrapper-cookbooks)
to configure and call the `rails_ubuntu` cookbook.

```
me@mymac $ chef-run --user vagrant --password vagrant demo-server-01 \
  rails_servers::demo_server
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

Set up your Rails application for deployment with Capistrano following
this guide.

https://gorails.com/deploy/ubuntu/18.04#capistrano

Run Capistrano for the first time to set up the standard deployment
directory structure.

```
my@mymac myapp $ bundle exec cap production deploy --hosts=vagrant-box
```

The `deploy` process will run any pending database migrations using `db:migrate`.
If you did not create a local database server and are using a separate database
machine, the migration will run and your production database will be updated
to match the new schema structure.

Anything more than `db:migrate` is too dangerous to automate for a production
environment so Capistrano leaves it for us to complete manually.

If you have an empty local database that needs more setup than a migration,
or if the migration from an empty database fails for any reason you can
manually run `db:setup`.

```
vagrant@vagrant-box $ cd /home/vagrant/activity-timer/releases/<latest-release>
vagrant@vagrant-box $ bundle exec bin/rails RAILS_ENV=production db:setup
```

If the initial deploy failed, run another deploy to set up the `myapp/current`
release pointer.

```
my@mymac myapp $ bundle exec cap production deploy --hosts=vagrant-box
```

Restart Nginx and navigate to your application to wake nginx/passenger
up to test it.

```
systemctl restart nginx
```

For a local vagrant server that would be something like `http://172.16.166.208`.

Once it is woken up, you can examine the passenger status.

```
# passenger-status
----------- Application groups -----------
/home/vagrant/activity-timer/current (production):
  App root: /home/vagrant/activity-timer/current
  Requests in queue: 0
  * PID: 14759   Sessions: 1       Processed: 6       Uptime: 26m 43s
    CPU: 0%      Memory  : 105M    Last used: 15m 34s ago
```

You can also restart the application after making changes.

```
# passenger-config restart-app /home/vagrant/activity-timer/current
Restarting /home/vagrant/activity-timer/current (production)
```

When in doubt, restart nginx again. This the most reliable way to reset
everything for a fresh start.

If nothing is working, make sure that the Rails runs from the command line
and examine `production.log` to see what is going wrong.

```
$ cd /home/vagrant/activity-timer/current
$ bundle exec bin/rails server -e production
$ vi log/production.log
```

Once your initial deployment is working, you can run `cap production deploy`
any time to keep all of your servers up to date with application changes.


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

Attributes: `db_type` (postgres | mysql), `db_user`, `db_password`, `db_name`

If `db_type` is not set, skip database setup.

Set `db_user`, `db_password` and `db_name` to create
the empty production database owned by `db_user`.

Feel free to configure the appropriate level of database
security and access. By default, the database servers
are only accessible from localhost.

## `postgres` - Install Postgres and create database ##

Postgres setup can be called directly or from the `database` recipe.

You can gain access to the `postgres` Postgres database role from
the `postgres` unix user.

```
sudo su postgres -c psql
```

## `mysql` - Install Mysql and create database ##

Mysql setup can be called directly or from the `database` recipe.

You can gain access to the `root` Mysql database user from
the `root` unix user.

```
sudo su -c mysql
```

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

Instead of modifying the `rails_ubuntu` cookbook, you can set up
a wrapper cookbook with recipes for the different kinds of servers
that you want to provision.

Navigate to your cookbooks directory and generate a new cookbook.

```
$ chef generate cookbook rails_servers
$ cd rails_servers
```

Add a line to the end of `Policyfile.rb` to specify the location of
the `rails_ubuntu` cookbook.

```
cookbook 'rails_ubuntu', github: 'jgorman/rails_ubuntu'
```

Add a line to the end of `metadata.rb` to tell Chef to load
the `rails_ubuntu` cookbook.

```
depends 'rails_ubuntu'
```

Then make a new recipe that configures your new server type.

```
$ cd recipes
$ cat >demo_server.rb
node.default['rails_ubuntu']['app_name']      = 'activity-timer'

node.default['rails_ubuntu']['db_type']       = 'postgres'
node.default['rails_ubuntu']['db_user']       = 'rails'
node.default['rails_ubuntu']['db_password']   = 'rails123'
node.default['rails_ubuntu']['db_name']       = 'activity_timer_prod'

include_recipe 'rails_ubuntu::setup_all'
```

You can include the `rails_ubuntu::setup_all` master recipe or only
include the individual recipes that make sense for you.

You can copy recipes from `rails_ubuntu` into your cookbook so that you
can customize them to better meet your needs.


# <a id="chef-run"></a>Chef-run Setup #

The easiest way to test your wrapper configuration is to use
`chef-run` to provision throwaway Vagrant servers.

You can spin up a fresh new Vagrant box, provision it,
and deploy your Rails application within minutes. Once that
works for your application you can deploy to a live Ubuntu server.

Download and install Chef Workstation

```
https://downloads.chef.io/chef-workstation/
```

Configure your default cookbook locations.

```
$ vi ~/.chef/config.rb
cookbook_path ["/Users/u/rails/github/chef/cookbooks"]
```

Configure the Chef debug log location. The `stack-trace.log` file
will be created in the same directory when there is a ruby
compile error.

```
$ vi ~/.chef-workstation/config.toml
[log]
level="debug"
location="/Users/u/rails/github/chef/chef-run.log"
```

For recipe debugging, `puts "Helpful debugging messages!"`
will show up in `chef-run.log`. You can `tail -f chef-run.log`
to watch the deployment progress in real time.


# <a id="vagrant"></a>Vagrant Setup #

Use the standard Chef Bento Ubuntu Vagrant boxes.

- 16.04 Xenial https://app.vagrantup.com/bento/boxes/ubuntu-16.04
- 18.04 Bionic https://app.vagrantup.com/bento/boxes/ubuntu-18.04

You will want to install Vagrant, Virtualbox and the
Virtualbox Extension Pack.
Here is the Homebrew command for OS X.

```
brew cask install vagrant virtualbox virtualbox-extension-pack
```

You can also download the
installers for your OS directly from Vagrant and Virtualbox.

- https://www.vagrantup.com/downloads.html
- https://www.virtualbox.org/wiki/Downloads

Make a directory, copy one of the Vagrantfiles below into it, bring up
the vm, and get the vm ip address.

```
me@mymac $ mkdir bento18
me@mymac $ cd bento18
me@mymac $ cat >Vagrantfile
me@mymac $ vagrant up
me@mymac $ vagrant ssh -c ifconfig | grep 'inet '
        inet 10.0.2.15  netmask 255.255.255.0  broadcast 10.0.2.255
        inet 172.28.128.17  netmask 255.255.255.0  broadcast 172.28.128.255
        inet 127.0.0.1  netmask 255.0.0.0
me@mymac $ ssh vagrant@172.28.128.17
vagrant@172.28.128.17's password: vagrant
vagrant@bento18 ~ $
```

You can run the standard Ubuntu Virtualbox Vagrant servers with these
`Vagrantfile` configurations.

## Ubuntu Xenial 16.04 Vagrantfile ##

```
Vagrant.configure('2') do |config|
  config.vm.box       = "bento/ubuntu-16.04"
  config.vm.hostname  = 'bento16'
  config.vm.provider    :virtualbox

  # Vagrant private network dhcp issue.
  # https://github.com/hashicorp/vagrant/issues/3083
  config.trigger.before [ :up, :reload, :provision ] do |trigger|
    trigger.ruby do |env,machine|
      `VBoxManage dhcpserver remove --netname HostInterfaceNetworking-vboxnet0 2>/dev/null`
    end
  end
  config.vm.network :private_network, type: :dhcp
end
```

## Ubuntu Bionic 18.04 Vagrantfile ##

```
Vagrant.configure('2') do |config|
  config.vm.box       = "bento/ubuntu-18.04"
  config.vm.hostname  = 'bento18'
  config.vm.provider    :virtualbox

  # Vagrant private network dhcp issue.
  # https://github.com/hashicorp/vagrant/issues/3083
  config.trigger.before [ :up, :reload, :provision ] do |trigger|
    trigger.ruby do |env,machine|
      `VBoxManage dhcpserver remove --netname HostInterfaceNetworking-vboxnet0 2>/dev/null`
    end
  end
  config.vm.network :private_network, type: :dhcp
end
```
