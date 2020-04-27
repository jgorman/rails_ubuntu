# frozen_string_literal: true

# Setup for test/integration/default.rb

node.default["rails_ubuntu"]["app_name"]      = "activity-timer"
node.default["rails_ubuntu"]["ruby_version"]  = "2.7.1"
node.default["rails_ubuntu"]["node_version"]  = "12"
node.default["rails_ubuntu"]["proxysql_version"] = "2.0"
node.default["rails_ubuntu"]["open_files"]    = 65535
node.default["rails_ubuntu"]["inotify"]       = 524288

node.default["rails_ubuntu"]["db_type"]       = "all"
node.default["rails_ubuntu"]["db_user"]       = "rails"
node.default["rails_ubuntu"]["db_password"]   = "rails123"
node.default["rails_ubuntu"]["db_name"]       = "activity_timer_prod"
node.default["rails_ubuntu"]["db_safe"]       = false
node.default["rails_ubuntu"]["redis_safe"]    = false
node.default["rails_ubuntu"]["proxysql_ssl"]  = true

node.default["rails_ubuntu"]["bash_aliases"]  += <<EOT

export PS1='\\u@\\h \\w \\\$ '
alias peg='ps -ef | grep'

alias tf='tail -f'
alias t9='tail -f -n 999'
alias c='clear'

alias va='vi ~/.bash_aliases; exec bash'
alias vb='vi ~/.bashrc; exec bash'
alias bb='exec bash'

[ -z "$R" ] && export R=~/#{node['rails_ubuntu']['app_name']}/current
alias S.='export R=`pwd`; R'
alias R='cd $R && ls -l'
alias Rcon='cd $R/config && ls -l'
alias Rlog='cd $R/log && ls -l'

temp_title() { echo -ne "\\033]0;${*}\\007"; }
title() { export PROMPT_COMMAND="echo -ne '\\033]0;${*}\\007'"; }
normal_title() { title `hostname`; }
normal_title
unalias vi 2>/dev/null
vi() {
  temp_title "`basename $1` "
  vim "$@"
}
EOT

# Node server testing.
# node.default["rails_ubuntu"]["app_type"] = "node"
# node.default["rails_ubuntu"]["app_name"] = "wifi-watch"
# node.default["rails_ubuntu"]["app_root"] = "#{Dir.home}/wifi-watch/wifi-service"
# node.default["rails_ubuntu"]["app_startup"] = "app.js"
# include_recipe "rails_ubuntu::nginx_passenger"

# Template replacement testing.
# edit_resource(:template, "/etc/nginx/sites-enabled/activity-timer") do
#  source "nginx_rails2.erb"
#  cookbook "rails_ubuntu"
# end

include_recipe "rails_ubuntu::server_rails"
include_recipe "rails_ubuntu::proxysql"
