# Add bash aliases to the root and deploy users.

default_aliases = <<EOT
alias l='ls -l'
alias la='ls -la'
alias lc='ls -C'
alias lt='ls -lrt'
EOT

bash_aliases = get(:bash_aliases) || default_aliases

file "/root/.bash_aliases" do
  content bash_aliases
end

file "/home/#{get(:deploy_user)}/.bash_aliases" do
  user get(:deploy_user)
  group get(:deploy_group)
  content bash_aliases
end
