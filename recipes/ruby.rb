# Build ruby with rbenv.

return if skip_recipe

deploy_user   = node['rails_ubuntu']['deploy_user']
deploy_group  = node['rails_ubuntu']['deploy_group']
ruby_version  = node['rails_ubuntu']['ruby_version']

unless File.exist?("#{Dir.home}/.rbenv")
  bash 'rbenv' do
    user  deploy_user
    group deploy_group
    code <<-EOT
      #{bash_began('rbenv')}

      git clone https://github.com/rbenv/rbenv.git ~/.rbenv
      echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
      echo 'eval "$(rbenv init -)"' >> ~/.bashrc
      git clone https://github.com/rbenv/ruby-build.git \
        ~/.rbenv/plugins/ruby-build
      echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' \
        >> ~/.bashrc
      git clone https://github.com/rbenv/rbenv-vars.git \
        ~/.rbenv/plugins/rbenv-vars

      #{bash_ended('rbenv')}
    EOT
  end
end

bash 'ruby' do
  user  deploy_user
  group deploy_group
  code <<-EOT
    #{bash_began('ruby')}

    ~/.rbenv/bin/rbenv install #{ruby_version}
    ~/.rbenv/bin/rbenv global #{ruby_version}
    ~/.rbenv/shims/gem install bundler

    #{bash_ended('ruby')}
  EOT
end
