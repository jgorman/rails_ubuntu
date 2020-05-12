# frozen_string_literal: true

# Build ruby with rbenv.

return if skip_recipe
return chef_log('installed') if File.exist?("#{Dir.home}/.rbenv")

deploy_user   = node['rails_ubuntu']['deploy_user']
deploy_group  = node['rails_ubuntu']['deploy_group'] || deploy_user

ruby_version  = node['rails_ubuntu']['ruby_version']
ruby_libs     = node['rails_ubuntu']['ruby_libs']

bash 'ruby_libs' do
  code <<~BASH
    #{bash_began('ruby_libs')}

    apt-get update -qq
    apt-get install -y -qq #{ruby_libs}

    #{bash_ended('ruby_libs')}
  BASH
end

bash 'rbenv' do
  user  deploy_user
  group deploy_group
  code <<~BASH
    #{bash_began('rbenv')}

    git clone https://github.com/rbenv/rbenv.git ~/.rbenv
    git clone https://github.com/rbenv/ruby-build.git \
      ~/.rbenv/plugins/ruby-build
    git clone https://github.com/rbenv/rbenv-vars.git \
      ~/.rbenv/plugins/rbenv-vars

    echo >> ~/.bashrc
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(rbenv init -)"' >> ~/.bashrc
    echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' \
      >> ~/.bashrc

    #{bash_ended('rbenv')}
  BASH
end

bash 'ruby_install' do
  user  deploy_user
  group deploy_group
  code <<~BASH
    #{bash_began('ruby_install')}

    ~/.rbenv/bin/rbenv install #{ruby_version}
    ~/.rbenv/bin/rbenv global #{ruby_version}
    ~/.rbenv/shims/gem install bundler

    #{bash_ended('ruby_install')}
  BASH
end
