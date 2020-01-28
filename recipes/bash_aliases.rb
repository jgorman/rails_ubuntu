# Add bash aliases to the root and deploy users.

return if skip_recipe
log_msg('began')

default_aliases = <<EOT
alias l='ls -l'
alias la='ls -la'
alias lc='ls -C'
alias lt='ls -lrt'
EOT

bash_aliases = get(:bash_aliases) || default_aliases

file '/root/.bash_aliases' do
  action :create_if_missing
  content bash_aliases
end
log_msg('working 2')

file "/home/#{get(:deploy_user)}/.bash_aliases" do
  user get(:deploy_user)
  group get(:deploy_group)
  action :create_if_missing
  content bash_aliases
end

log_msg('ended')
