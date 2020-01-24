# Capistrano runs as the deploy user so we install the deploy ruby with rbenv.

bash "deploy_ruby" do
  user get(:deploy_user)
  group get(:deploy_group)
  not_if { ::File.exist?('~/.rbenv') }
  code <<-EOT
    exec >>~/chef.log 2>&1
    echo -e "===\nLog deploy_ruby began `date`\n"

    git clone https://github.com/rbenv/rbenv.git ~/.rbenv
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(rbenv init -)"' >> ~/.bashrc
    git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
    echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
    git clone https://github.com/rbenv/rbenv-vars.git ~/.rbenv/plugins/rbenv-vars

    ~/.rbenv/bin/rbenv install #{get(:ruby_version)}
    ~/.rbenv/bin/rbenv global #{get(:ruby_version)}

    echo -e "\nLog deploy_ruby ended `date`"
  EOT
end
