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

alias tf='tail -f'
alias t9='tail -f -n 999'
alias c='clear'

alias va='vi ~/.bash_aliases; exec bash'
alias vb='vi ~/.bashrc; exec bash'
alias bb='exec bash'

export R=~/activity-timer/current
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

node.default['rails_ubuntu']['db_type'] = 'both'
include_recipe 'rails_ubuntu::setup_all'
