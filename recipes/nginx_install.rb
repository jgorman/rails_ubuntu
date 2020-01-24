# Install and start nginx and passenger.

platform_version = node['platform_version']
ubuntu_name =
  case platform_version
  when '16.04'
    'xenial'
  when '18.04'
    'bionic'
  else
    raise "Untested ubuntu version '#{platform_version}'"
  end

bash 'nginx_install' do
  code <<-EOT
    exec >>~/chef.log 2>&1
    chmod a+w ~/chef.log
    echo -e "===\nLog nginx_install began `date`\n"

    apt-key adv \
      --keyserver hkp://keyserver.ubuntu.com:80 \
      --recv-keys 561F9B9CAC40B2F7

    echo 'deb https://oss-binaries.phusionpassenger.com/apt/passenger #{ubuntu_name} main' > /etc/apt/sources.list.d/passenger.list

    apt-get update
  EOT
end

case platform_version

when '16.04'
  bash 'nginx-16.04' do
    code <<-EOT
      exec >>~/chef.log 2>&1
      chmod a+w ~/chef.log
      echo -e "\nRunning nginx-xenial `date`"
      apt-get install -y -qq nginx-extras passenger
    EOT
  end

  replace_or_add 'nginx.conf' do
    path '/etc/nginx/nginx.conf'
    pattern '.*passenger.conf.*'
    line 'include /etc/nginx/passenger.conf;'
  end

  replace_or_add 'passenger.conf' do
    def get(key); node[@cookbook_name][key] end
    path '/etc/nginx/passenger.conf'
    pattern '.*passenger_ruby.*'
    line "passenger_ruby /home/#{get(:deploy_user)}/.rbenv/shims/ruby;"
  end

when '18.04'
  bash 'nginx-18.04' do
    code <<-EOT
      exec >>~/chef.log 2>&1
      chmod a+w ~/chef.log
      echo -e "\nRunning nginx-bionic `date`"
      apt-get install -y -qq nginx-extras libnginx-mod-http-passenger
      [ -f /etc/nginx/modules-enabled/50-mod-http-passenger.conf ] ||
        ln -s /usr/share/nginx/modules-available/mod-http-passenger.load \
          /etc/nginx/modules-enabled/50-mod-http-passenger.conf
    EOT
  end

  replace_or_add 'mod-http-passenger.conf' do
    def get(key); node[@cookbook_name][key] end
    path '/etc/nginx/conf.d/mod-http-passenger.conf'
    pattern '.*passenger_ruby.*'
    line "passenger_ruby /home/#{get(:deploy_user)}/.rbenv/shims/ruby;"
  end

else
  raise "Untested ubuntu version '#{platform_version}'"
end

file '/etc/nginx/sites-enabled/default' do
  action :delete
end

template "/etc/nginx/sites-enabled/#{get(:app_name)}" do
  helper(:get) {|key| node[@cookbook_name][key] }
  source "nginx_site.erb"
end

service 'nginx' do
  action [ :enable, :start ]
end

bash 'nginx-ended' do
  code <<-EOT
    exec >>~/chef.log 2>&1
    chmod a+w ~/chef.log
    echo -e "\nLog nginx_install ended `date`"
  EOT
end
