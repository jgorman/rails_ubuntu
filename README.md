# rails_ubuntu Chef Cookbook

A Chef cookbook to provision Ubuntu for [Rails](#recipes) and
[Node](#recipes) deployment using Nginx, Passenger, and Capistrano.

This cookbook is modeled on the excellent Go Rails deployment guide.
A big shout out to [Chris Oliver](https://gorails.com/users/1)!

- https://gorails.com/deploy/ubuntu/18.04

Tested on Ubuntu 16.04 and 18.04 with Postgres and MySQL.

Available from the Chef Supermarket or the latest version on Github.

- https://supermarket.chef.io/cookbooks/rails_ubuntu
- https://github.com/jgorman/rails_ubuntu

Here are four steps to a running Ubuntu Rails or Node application.

1. [SSH Key Forwarding](#1-ssh-key-forwarding)
2. [Add the Deploy User](#2-add-the-deploy-user)
3. [Provision the Server With Chef](#3-provision-the-server-with-chef)
4. [Deploy Your Application With Capistrano](#4-deploy-your-application-with-capistrano)

Then you can run `cap production deploy` any time to effortlessly update
your applications running on all of your test, staging, and production servers!

See below for more information.

- [Recipes](#recipes)
- [Attribute Defaults](#attribute-defaults)
- [Wrapper Cookbooks](#wrapper-cookbooks)
- [Chef-Run Setup](#chef-run-setup)
- [Vagrant Setup](#vagrant-setup)
- [Troubleshooting](#troubleshooting)

# 1. SSH Key Forwarding #

Both Chef and Capistrano depend on you forwarding your ssh key from
your workstation to the target server.

Add your key to ssh-agent.

```bash
ssh-add -K # Add your id_rsa key to the keychain.
ssh-add -L # You should see your key.
```

Configure ssh-agent key forwarding.

```
vi ~/.ssh/config
Host *
ForwardAgent yes
```


# 2. Add the Deploy User #

These instructions are for setting up the deploy user for a live server.
See the section below for [Vagrant setup](#vagrant-setup).

### 2.1. Deploy User with Passwordless Sudo ###

Any user name will work, such as the default user name `vagrant`
for a Vagrant box.

```bash
root $ adduser vagrant
root $ echo 'vagrant ALL=(ALL) NOPASSWD: ALL' >/etc/sudoers.d/vagrant
root $ su vagrant
vagrant $ sudo su # No password prompt.
root $
```

### 2.2. Deploy User with Passwordless SSH ###

Set up passwordless ssh from your workstation user to the deploy user.

```
me@mymac $ brew install ssh-copy-id
me@mymac $ ssh-copy-id vagrant@bento18
vagrant@bento18's password:
Number of key(s) added:        1
me@mymac $ ssh vagrant@bento18
vagrant@bento18 $
```


# 3. Provision the Server With Chef #

Here is an example of using a [wrapper cookbook](#wrapper-cookbooks)
to configure and call the `rails_ubuntu` cookbook.

```
me@mymac $ cd cookbooks/my_wrapper
me@mymac $ chef-run vagrant@bento18 my_wrapper::myapp_recipe
```

If you see the message
`dpkg: error: dpkg status database is locked by another process`,
this is Ubuntu running the post-boot automatic package upgrade.
Wait for a few minutes for this to complete and try running the cookbook again.

In order to make sense of what is happening and to see errors the recipes
all log to `~deploy/chef.log`. You can watch the provisioning process
run on the target server in real time.

```
vagrant@bento18 ~ $ touch chef.log
vagrant@bento18 ~ $ tail -f chef.log
```

# 4. Deploy Your Application With Capistrano #

Set up your workstation with the Capistrano gems.

```
gem install capistrano capistrano-rails capistrano-passenger capistrano-rbenv
```

Set up your application for deployment with Capistrano following
this guide.

https://gorails.com/deploy/ubuntu/18.04#capistrano

Run Capistrano for the first time to set up the standard deployment
directory structure.

```
my@mymac myapp $ bundle exec cap production deploy
```

Once your initial deployment is working, you can run `cap production deploy`
any time to keep all of your servers up to date with application changes.


# Recipes #

## Server Setup Recipes ##

- `server_rails` - Complete Rails server includes all features.
- `server_node` - Complete Node server without Ruby.
- `server_database` - Database server: Postgres or MySQL.
- `server_postgres` - Postgres server.
- `server_mysql` - MySQL server.
- `server_proxysql` - ProxySQL MySQL proxy server.
- `server_redis` - Redis server.
- `server_ruby` - Capistrano deploy workstation.
- `server_basic` - Basic tools.

You can set the `skip_recipes` attribute to skip unnecessary features.

```ruby
node.default["rails_ubuntu"]["skip_recipes"] = "ripgrep, redis"
```

## Feature Recipes ##

## `apt_upgrade` - Upgrade all packages ##

Always a good idea when provisioning a new server.

## `apt_install` - Install basic packages ##

Attributes: `apt_install`, `open_files`

You can replace or extend the basic package list.
See [Attribute Defaults](#attribute-defaults) for the current list.

```ruby
node.default["rails_ubuntu"]["apt_install"] += " sqlite3"
```

## `tune` - Tune OS limits ##

Update the number of open files allowed, which takes effect
on the next server reboot. Set `nofile = 0` to disable this.

Update the number of files that can be watched for changes.
Set `inotify = 0` to disable this.


## `bash_aliases` - Add bash aliases to the root and deploy users ##

For those of us with muscle memory. You can set `bash_aliases` with your own bash shortcuts. See the `setup_test` recipe for an example.

Attributes: `bash_aliases`, `deploy_user`, `deploy_group`

You can replace or extend the `.bash_aliases` file content.
See [Attribute Defaults](#attribute-defaults) for the current list.

```ruby
node.default["rails_ubuntu"]["bash_aliases"] += <<EOT
export PS1='\\u@\\h \\w \\\$ '
alias peg='ps -ef | grep'
alias c='clear'
EOT
```

## `ripgrep` - Install Ripgrep ##

Useful for figuring out how things are configured
in the application code and in the bundled gems.

```
rg --hidden DATABASE_URL
```

## `ruby` - Build Ruby with Rbenv ##

Attributes: `ruby_version`, `deploy_user`, `deploy_group`, `ruby_libs`

You can set your preferred ruby version.

```ruby
node.default["rails_ubuntu"]["ruby_version"] = "2.7.1"
```

You can replace or extend the ruby library packages.
See [Attribute Defaults](#attribute-defaults) for the current list.

```ruby
node.default["rails_ubuntu"]["ruby_libs"] += " libncurses5-dev"
```

## `node` - Install Node and Yarn ##

Attributes: `node_version`

The current default node.js version is `12`. This is the latest LTS version.

## `redis` - Install Redis service ##

Attributes: `redis_safe`

Install Redis for Action Cable websocket support.

By default redis plays it safe and only listens to server local connections.
You can open redis to outside connections.

```ruby
node.default["rails_ubuntu"]["redis_safe"] = false
```

## `nginx_passenger` - Install Nginx and Passenger ##

Attributes: `deploy_user`, `deploy_group`

- `server_name` = node["fqdn"]
- `app_type`    = "rails" # rails | node
- `app_env`     = "production"
- `app_startup` = "app.js"
- `app_name`    = "myapp"
- `nginx_site`  = app_name
- `deploy_home` = "/home/<deploy_user>"
- `deploy_to`   = "<deploy_home>/<app_name>"
- `app_root`    = "<deploy_to>/current"
- `app_public`  = "<app_root>/public"

This recipe will create the `deploy_to` directory if it does not exist.
You can specify the `deploy_to` directory location or it will default
to `app_name` in the `deploy_user`'s home directory.

A template from `rails_ubuntu/templates` is used to
create the `/etc/nginx/sites-enabled/<nginx_site>`
Nginx configuration file. After this is run you can examine the file
and adjust it as necessary.

You can also substitute your own nginx template file from your
wrapper cookbook. Copy the one that you would like to alter
from `rails_ubuntu/templates` into
the same location in your wrapper cookbook and edit it.

Be sure to invoke `edit_resource` after you have included
the recipe that includes the `nginx_passenger` recipe so that
the nginx template resource is there to edit.

```ruby
node.default["rails_ubuntu"]["app_name"] = "activity-timer"
include_recipe "rails_ubuntu::server_rails"

edit_resource!(:template, "/etc/nginx/sites-enabled/activity-timer") do
  source "nginx_rails.erb"
  cookbook "my_wrapper"
end
```

Your template has access to all of the attributes listed above.

## `database` - Install Postgres or MySQL and create database ##

Attributes: `db_type` (postgres | mysql)

Attributes: `db_user`, `db_password`, `db_name`, `db_safe`

If `db_type` is not set, skip database setup.

Set `db_user`, `db_password` and `db_name` to create
the empty production database owned by `db_user`.

By default the database servers play it safe and only listen to
server local connections. You can open them up to outside connections.

```ruby
node.default["rails_ubuntu"]["db_safe"] = false
```

## `postgres` - Install Postgres and create database ##

Postgres setup can be called directly or via the `database` recipe.

You can gain access to the `postgres` Postgres database role from
the `postgres` unix user.

```
sudo su postgres -c psql
```

## `mysql` - Install MySQL and create database ##

MySQL setup can be called directly or via the `database` recipe.

You can gain access to the `root` MySQL database user from
the `root` unix user.

```
sudo su -c mysql
```

## `proxysql` - Install ProxySQL MySQL proxy service ##

Attributes: `proxysql_version`, `proxysql_ssl`

Access the admin interface on port 6032 to set up the hosts and users.

```
mysql -u admin -padmin -h 127.0.0.1 -P 6032 --prompt="Admin> "
```

Access the data interface on port 6033.

Set `proxysql_ssl == true`, to configure the data interface for
ssl transport. This does not protect the socket itself from login or
protocol attacks. Don't expose either socket to the open internet.
Use a VPN or ssh tunnel between servers when traversing an untrusted network.

## `setup_test` - Wrapper example ##

An example of how to wrap and call the `rails_ubuntu` recipes
from another cookbook.

It also sets up for Chef Cookbook Kitchen testing located at
`test/integration/setup_test/default.rb`


# Attribute Defaults #

See `rails_ubuntu/attributes/defaults.rb`

```ruby
default["rails_ubuntu"]["deploy_user"]    = "vagrant"
# default["rails_ubuntu"]["deploy_group"] = "<deploy_user>"
# default["rails_ubuntu"]["deploy_home"]  = "/home/<deploy_user>"

default["rails_ubuntu"]["ruby_version"]   = "2.7.1"
default["rails_ubuntu"]["node_version"]   = "12"
default["rails_ubuntu"]["proxysql_version"] = "2.0"

default["rails_ubuntu"]["nofile"]         =  65535    # 0 for no effect.
default["rails_ubuntu"]["inotify"]        = 524288    # 0 for no effect.

# Generate /etc/nginx/sites-enabled/<nginx_site> from template.
default["rails_ubuntu"]["server_name"]    = node["fqdn"]
default["rails_ubuntu"]["app_type"]       = "rails"   # rails | node
default["rails_ubuntu"]["app_env"]        = "production"
default["rails_ubuntu"]["app_startup"]    = "app.js"  # Node app boot file.
default["rails_ubuntu"]["app_name"]       = "myapp"
# default["rails_ubuntu"]["nginx_site"]   = app_name
# default["rails_ubuntu"]["deploy_to"]    = "<deploy_home>/<app_name>"
# default["rails_ubuntu"]["app_root"]     = "<deploy_to>/current"
# default["rails_ubuntu"]["app_public"]   = "<app_root>/public"

# Local database server.
default["rails_ubuntu"]["db_type"]        = "none"    # none | postgres | mysql
# default["rails_ubuntu"]["db_user"]      =
# default["rails_ubuntu"]["db_password"]  =
# default["rails_ubuntu"]["db_name"]      =
default["rails_ubuntu"]["db_safe"]        = true      # true | false

default["rails_ubuntu"]["proxysql_ssl"]   = false     # false | true

default["rails_ubuntu"]["redis_safe"]     = true      # true | false

default["rails_ubuntu"]["skip_recipes"]   = ""        # "redis bash_aliases"

default["rails_ubuntu"]["bash_aliases"]   = <<ALIASES
alias l='ls -l'
alias la='ls -la'
alias lc='ls -C'
alias lt='ls -lrt'
ALIASES

default["rails_ubuntu"]["apt_install"] =
  "git-core build-essential software-properties-common \
   vim curl apt-transport-https ca-certificates dirmngr gnupg"

default["rails_ubuntu"]["ruby_libs"] =
  "libcurl4-openssl-dev libffi-dev libreadline-dev libsqlite3-dev \
   libssl-dev libxml2-dev libxslt1-dev libyaml-dev sqlite3 zlib1g-dev"
```


# Wrapper Cookbooks #

Instead of modifying the `rails_ubuntu` cookbook, you can set up
a wrapper cookbook with recipes for the different kinds of servers
that you want to provision.

Navigate to your cookbooks directory and generate a new cookbook.

```
$ cd && mkdir cookbooks && cd cookbooks
$ chef generate cookbook my_wrapper
$ cd my_wrapper
```

Add a line to the end of `Policyfile.rb` to specify the location of
the `rails_ubuntu` cookbook.

From the Chef Cookbook Supermarket.

```ruby
cookbook "rails_ubuntu", "~> 0.1", :supermarket
```

Or use the latest Github version.

```ruby
cookbook "rails_ubuntu", github: "jgorman/rails_ubuntu"
```

Add a line to the end of `metadata.rb` to tell Chef to load
the `rails_ubuntu` cookbook.

```ruby
depends "rails_ubuntu"
```

Then make a new recipe that configures your new server type.

```ruby
$ cd recipes
$ vi myapp_recipe.rb
node.default["rails_ubuntu"]["app_name"]      = "activity-timer"

node.default["rails_ubuntu"]["db_type"]       = "postgres"
node.default["rails_ubuntu"]["db_user"]       = "rails"
node.default["rails_ubuntu"]["db_password"]   = "rails123"
node.default["rails_ubuntu"]["db_name"]       = "activity_timer_prod"

include_recipe "rails_ubuntu::server_rails"
```

You can include the `rails_ubuntu::server_rails` server recipe or only
include the individual feature recipes that make sense for you.

You can copy recipes from `rails_ubuntu` into your cookbook so that you
can customize them to better meet your needs.


# Chef-run Setup #

The easiest way to test your wrapper configuration is to use
`chef-run` to provision throwaway Vagrant servers.

You can spin up a fresh new Vagrant box, provision it,
and deploy your application within minutes. Once that
works for your application you can deploy to a live Ubuntu server.

Download and install Chef Workstation

```
https://downloads.chef.io/chef-workstation/
```

Configure your default cookbook locations.

```bash
$ vi ~/.chef/config.rb
cookbook_path ["/Users/me/cookbooks"]
```

Configure the Chef debug log location. The `stack-trace.log` file
will be created in the same directory when there is a ruby
compile error.

```bash
$ vi ~/.chef-workstation/config.toml
[log]
level="debug"
location="/Users/me/cookbooks/chef-run.log"
```

For recipe debugging, `puts "Helpful debugging messages!"`
will show up in `chef-run.log`. You can `tail -f chef-run.log`
to watch the deployment progress in real time.


# Vagrant Setup #

You can use the standard Ubuntu or Chef Bento Vagrant boxes.

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
the vm, and get the dhcp assigned ip address. You can assign a name to
the ip address in `/etc/hosts`.

```
me@mymac $ mkdir bento18
me@mymac $ cd bento18
me@mymac $ vi Vagrantfile
me@mymac $ vagrant up
me@mymac $ vagrant ssh -c 'ip addr show' | grep 'inet '
        inet 10.0.2.15  netmask 255.255.255.0  broadcast 10.0.2.255
        inet 172.28.128.17  netmask 255.255.255.0  broadcast 172.28.128.255
        inet 127.0.0.1  netmask 255.0.0.0
me@mymac $ sudo vi /etc/hosts
172.28.128.17 bento18
me@mymac $ ssh vagrant@bento18
vagrant@bento18 $
```

If you get a `permission denied (publickey)` error when logging in with
a password, you may want to enable this.

```
me@mymac $ vagrant ssh
vagrant@bento18 $ sudo vi /etc/ssh/sshd_config
PasswordAuthentication yes
vagrant@bento18 $ sudo systemctl restart sshd
```

Here are some example Vagrantfile configurations.

`Private Network` will make your VM visible from within your workstation.
If you have several VMs, for example a database server, a redis server
and a Rails server, they will be able to communicate with each other.

`Public Network` will make your VM visible within the same network that
your workstation is in, as if it was a separate workstation.

## Ubuntu 16.04 Private Network Vagrantfile ##

```ruby
Vagrant.configure("2") do |config|
  config.vm.box       = "bento/ubuntu-16.04"
  config.vm.hostname  = "bento16"
  config.vm.provider    :virtualbox do |v|
    v.cpus = 4
  end

  # Private network issue. https://github.com/hashicorp/vagrant/issues/3083
  config.trigger.before [ :up, :reload, :provision ] do |trigger|
    trigger.ruby do |env,machine|
      `VBoxManage dhcpserver remove --netname HostInterfaceNetworking-vboxnet0 2>/dev/null`
    end
  end

  config.vm.network :private_network, type: :dhcp
end
```

## Ubuntu 18.04 Private Network Vagrantfile ##

```ruby
Vagrant.configure("2") do |config|
  config.vm.box       = "bento/ubuntu-18.04"
  config.vm.hostname  = "bento18"
  config.vm.provider    :virtualbox do |v|
    v.cpus = 4
  end

  # Private network issue. https://github.com/hashicorp/vagrant/issues/3083
  config.trigger.before [ :up, :reload, :provision ] do |trigger|
    trigger.ruby do |env,machine|
      `VBoxManage dhcpserver remove --netname HostInterfaceNetworking-vboxnet0 2>/dev/null`
    end
  end

  config.vm.network :private_network, type: :dhcp
end
```

## Ubuntu 18.04 Public Network Vagrantfile ##

```ruby
Vagrant.configure("2") do |config|
  config.vm.box       = "bento/ubuntu-18.04"
  config.vm.hostname  = "public"
  config.vm.provider    :virtualbox do |v|
    v.cpus = 4
  end

  config.vm.network :public_network
end
```

You will be prompted for the network that your VM will appear on.
You can avoid future prompts by specifying the exact bridge description string.

```ruby
config.vm.network :public_network, bridge: "en0: Wi-Fi (AirPort)"
```


# Troubleshooting #

Make sure that your application runs from the command line and examine
`production.log` to look for issues.

```
$ cd /home/vagrant/activity-timer/current
$ bundle exec bin/rails server -e production
$ vi log/production.log
```

Restart Nginx and navigate to your application to wake nginx/passenger
up to test it.

```
systemctl restart nginx
```

Once it is woken up, you can examine the Passenger status.

```
# passenger-status
----------- Application groups -----------
/home/deploy/activity-timer/current (production):
  App root: /home/deploy/activity-timer/current
  Requests in queue: 0
  * PID: 11517   Sessions: 0       Processed: 2       Uptime: 4s
    CPU: 13%     Memory  : 35M     Last used: 4s ago
```

You can ask Passenger to restart the application after making changes.

```
# passenger-config restart-app /
Restarting /home/vagrant/activity-timer/current (production)
```

If `passenger-status` is not showing your application, look at the
Nginx error and access logs.

```
# vi /var/log/nginx/error.log
```

When in doubt, restart nginx again which will completely reload and restart
passenger since passenger is running inside of nginx as a loadable module.
This the most reliable way to reset everything for a fresh start.
