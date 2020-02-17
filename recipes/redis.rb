# Install redis service.

return if skip_recipe

redis_safe = node['rails_ubuntu']['redis_safe']

bash 'redis' do
  code <<-EOT
    #{bash_began}

    [ -e /etc/apt/sources.list.d/chris-lea-ubuntu-redis-server-xenial.list ] ||
      add-apt-repository -y ppa:chris-lea/redis-server

    apt-get update -qq
    apt-get install -y -qq redis-server redis-tools

    #{bash_ended}
  EOT
end

if redis_safe == 'unsafe'
  replace_or_add 'redis_unprotected' do
    path '/etc/redis/redis.conf'
    pattern '^protected-mode.*'
    line 'protected-mode no'
  end

  bash 'redis_unbound' do
    code <<-EOT
      #{bash_began('redis_unbound')}

      sed -i -e 's/^bind/#bind/' /etc/redis/redis.conf
      systemctl restart redis

      #{bash_ended('redis_unbound')}
    EOT
  end
end

service 'redis-server' do
  action [ :enable, :start ]
end
