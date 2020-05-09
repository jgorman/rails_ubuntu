# frozen_string_literal: true

# Build ruby with rbenv.

# There is a Chef Workstation 0.18.3 bug on Ubuntu 20.04.
# $HOME is set to /root instead of /home/vagrant.
# The workaround is "su - vagrant".

return if skip_recipe

deploy_user   = node["rails_ubuntu"]["deploy_user"]
deploy_home   = node["rails_ubuntu"]["deploy_home"] || "/home/#{deploy_user}"

ruby_version  = node["rails_ubuntu"]["ruby_version"]
ruby_libs     = node["rails_ubuntu"]["ruby_libs"]

bash "ruby_libs" do
  code <<~BASH
    #{bash_began("ruby_libs")}

    apt-get update -qq
    apt-get install -y -qq #{ruby_libs}

    #{bash_ended("ruby_libs")}
  BASH
end

unless File.exist?("#{deploy_home}/.rbenv")
  bash "rbenv" do
    code <<~BASH
      #{bash_began("rbenv")}

      su - #{deploy_user} <<'RBENV'
        git clone https://github.com/rbenv/rbenv.git .rbenv
        echo >> .bashrc
        echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> .bashrc
        echo 'eval "$(rbenv init -)"' >> .bashrc
        git clone https://github.com/rbenv/ruby-build.git \
          .rbenv/plugins/ruby-build
        echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' \
          >> .bashrc
        git clone https://github.com/rbenv/rbenv-vars.git \
          .rbenv/plugins/rbenv-vars
      RBENV

      #{bash_ended("rbenv")}
    BASH
  end
end

bash "ruby_install" do
  code <<~BASH
    #{bash_began("ruby_install")}

    su - #{deploy_user} <<RBENV
      .rbenv/bin/rbenv install #{ruby_version}
      .rbenv/bin/rbenv global #{ruby_version}
      .rbenv/shims/gem install bundler
    RBENV

    #{bash_ended("ruby_install")}
  BASH
end
