# Install redis service.

return if skip_recipe

bash "redis" do
  code <<-EOT
    #{bash_began}

    [ -e /etc/apt/sources.list.d/chris-lea-ubuntu-redis-server-xenial.list ] ||
      add-apt-repository -y ppa:chris-lea/redis-server

    apt-get update
    apt-get install -y -qq redis-server redis-tools

    #{bash_ended}
  EOT
end

service 'redis-server' do
  action [ :enable, :start ]
end
