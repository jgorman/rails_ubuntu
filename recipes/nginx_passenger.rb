# Install nginx and passenger.

# https://www.phusionpassenger.com/library/install/nginx/install/oss/

return if skip_recipe

server_name = node['rails_ubuntu']['server_name']
app_name    = node['rails_ubuntu']['app_name']
deploy_to   = node['rails_ubuntu']['deploy_to']
deploy_user = node['rails_ubuntu']['deploy_user']

deploy_dir  = deploy_to || "/home/#{deploy_user}/#{app_name}"

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

log_msg('began')

bash 'nginx_passenger' do
  code <<-EOT
    apt-key adv \
      --keyserver hkp://keyserver.ubuntu.com:80 \
      --recv-keys 561F9B9CAC40B2F7

    echo 'deb https://oss-binaries.phusionpassenger.com/apt/passenger #{ubuntu_name} main' > /etc/apt/sources.list.d/passenger.list

    apt-get update -qq
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

  replace_or_add 'passenger.conf' do
    path '/etc/nginx/passenger.conf'
    pattern '.*passenger_ruby.*'
    line "passenger_ruby /home/#{deploy_user}/.rbenv/shims/ruby;"
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

  replace_or_add 'mod-http-passenger.conf' do
    path '/etc/nginx/conf.d/mod-http-passenger.conf'
    pattern '.*passenger_ruby.*'
    line "passenger_ruby /home/#{deploy_user}/.rbenv/shims/ruby;"
  end

else
  raise "Untested Ubuntu version '#{platform_version}'"
end

link '/etc/nginx/sites-enabled/default' do
  action :delete
end

template "/etc/nginx/sites-enabled/#{app_name}" do
  source 'nginx_site.erb'
  action :create_if_missing
  variables(
    server_name:  "#{server_name}",
    app_name:     "#{app_name}",
    deploy_dir:   "#{deploy_dir}")
end

service 'nginx' do
  action [ :enable, :start ]
end

log_msg('ended')
