# Build ruby with rbenv.

return if skip_recipe

unless ::File.exist?("/home/#{get(:deploy_user)}/.rbenv")

  bash "ruby" do
    user get(:deploy_user)
    group get(:deploy_group)
    code <<-EOT
      #{bash_began}

      git clone https://github.com/rbenv/rbenv.git ~/.rbenv
      echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
      echo 'eval "$(rbenv init -)"' >> ~/.bashrc
      git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
      echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
      git clone https://github.com/rbenv/rbenv-vars.git ~/.rbenv/plugins/rbenv-vars

      ~/.rbenv/bin/rbenv install #{get(:ruby_version)}
      ~/.rbenv/bin/rbenv global #{get(:ruby_version)}
      ~/.rbenv/shims/gem install bundler

      #{bash_ended}
    EOT
  end

end
