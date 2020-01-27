# Wrapper example.

node.default['rails_ubuntu']['app_name']      = 'activity-timer'

node.default['rails_ubuntu']['db_type']       = 'postgres'
node.default['rails_ubuntu']['db_user']       = 'rails'
node.default['rails_ubuntu']['db_password']   = 'rails123'
node.default['rails_ubuntu']['db_name']       = 'activity_timer_prod'

node.default['rails_ubuntu']['bash_aliases']  = <<EOT
alias l='ls -l'
alias la='ls -la'
alias lc='ls -C'
alias lt='ls -lrt'

export PS1='\\u@\\h \\w \\\$ '
alias peg='ps -ef | grep'

alias va='vi ~/.bash_aliases; exec bash'
alias vb='vi ~/.bashrc; exec bash'
alias bb='exec bash'

export R=~/activity-timer/current
alias R='cd $R && ls -l'
alias Rcon='cd $R/config && ls -l'
alias Rlog='cd $R/log && ls -l'
EOT

#include_recipe 'rails_ubuntu::setup_all'
include_recipe 'rails_ubuntu::bash_aliases'
#include_recipe 'rails_ubuntu::database'
