# Add bash aliases to the root and deploy users.

return if skip_recipe

bash_aliases  = node['rails_ubuntu']['bash_aliases']
deploy_user   = node['rails_ubuntu']['deploy_user']
deploy_group  = node['rails_ubuntu']['deploy_group']

default_aliases = <<EOT
alias l='ls -l'
alias la='ls -la'
alias lc='ls -C'
alias lt='ls -lrt'
EOT

aliases = bash_aliases || default_aliases

chef_log('began')

file '/root/.bash_aliases' do
  action :create_if_missing
  content aliases
end

file "#{Dir.home}/.bash_aliases" do
  user  deploy_user
  group deploy_group
  action :create_if_missing
  content aliases
end

chef_log('ended')
