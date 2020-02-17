# Install nginx and passenger.

# https://www.phusionpassenger.com/library/install/nginx/install/oss/

return if skip_recipe

deploy_user   = node['rails_ubuntu']['deploy_user']
deploy_group  = node['rails_ubuntu']['deploy_group']

server_name   = node['rails_ubuntu']['server_name']
app_type      = node['rails_ubuntu']['app_type'] || 'rails'
rails_env     = node['rails_ubuntu']['rails_env']
app_env       = node['rails_ubuntu']['app_env'] || rails_env || 'production'
app_name      = node['rails_ubuntu']['app_name'] || 'myapp'
deploy_to     = node['rails_ubuntu']['deploy_to'] || "#{Dir.home}/#{app_name}"
app_root      = node['rails_ubuntu']['app_root'] || "#{deploy_to}/current"
app_public    = node['rails_ubuntu']['app_public'] || "#{app_root}/public"
app_startup   = node['rails_ubuntu']['app_startup'] || 'app.js'

platform_version = node['platform_version']
ubuntu_name =
  case platform_version
  when '16.04'
    'xenial'
  when '18.04'
    'bionic'
  else
    raise "Untested Ubuntu version '#{platform_version}'"
  end

chef_log('began')

directory deploy_to do
  owner deploy_user
  group deploy_group
  mode '0755'
  recursive true
  action :create
end

bash 'nginx_passenger' do
  code <<-EOT
    #{bash_began}

    apt-key adv \
      --keyserver hkp://keyserver.ubuntu.com:80 \
      --recv-keys 561F9B9CAC40B2F7

    echo 'deb https://oss-binaries.phusionpassenger.com/apt/passenger #{ubuntu_name} main' > /etc/apt/sources.list.d/passenger.list

    apt-get update -qq

    #{bash_ended}
  EOT
end

case platform_version

when '16.04'
  bash 'nginx-16.04' do
    code <<-EOT
      #{bash_began('nginx-16.04')}

      apt-get install -y -qq nginx-extras passenger

      #{bash_ended('nginx-16.04')}
    EOT
  end

  replace_or_add 'nginx.conf' do
    path '/etc/nginx/nginx.conf'
    pattern '.*passenger.conf.*'
    line 'include /etc/nginx/passenger.conf;'
  end

  bash 'passenger.conf' do
    code <<-EOT
      #{bash_began('passenger.conf')}

      [ -e #{Dir.home}/.rbenv ] && {
        pc=/etc/nginx/passenger.conf
        sed -i -e "s@^passenger_ruby.*@passenger_ruby #{Dir.home}/.rbenv/shims/ruby;@" $pc
      }

      #{bash_ended('passenger.conf')}
    EOT
  end

when '18.04', '20.04'
  bash 'nginx-18.04' do
    code <<-EOT
      #{bash_began('nginx-18.04')}

      apt-get install -y -qq nginx-extras libnginx-mod-http-passenger
      [ -f /etc/nginx/modules-enabled/50-mod-http-passenger.conf ] ||
        ln -s /usr/share/nginx/modules-available/mod-http-passenger.load \
          /etc/nginx/modules-enabled/50-mod-http-passenger.conf

      #{bash_ended('nginx-18.04')}
    EOT
  end

  bash 'passenger.conf' do
    code <<-EOT
      #{bash_began('passenger.conf')}

      [ -e #{Dir.home}/.rbenv ] && {
        pc=/etc/nginx/conf.d/mod-http-passenger.conf
        sed -i -e "s@^passenger_ruby.*@passenger_ruby #{Dir.home}/.rbenv/shims/ruby;@" $pc
      }

      #{bash_ended('passenger.conf')}
    EOT
  end

else
  raise "Untested Ubuntu version '#{platform_version}'"
end

link '/etc/nginx/sites-enabled/default' do
  action :delete
end

template "/etc/nginx/sites-enabled/#{app_name}" do
  source "nginx_#{app_type}.erb"
  action :create_if_missing
  variables(
    deploy_user: deploy_user,
    deploy_group: deploy_group,
    server_name: server_name,
    app_type: app_type,
    app_env: app_env,
    app_name: app_name,
    deploy_to: deploy_to,
    app_root: app_root,
    app_public: app_public,
    app_startup: app_startup
  )
end

service 'nginx' do
  action [ :enable, :restart ]
end

chef_log('ended')
