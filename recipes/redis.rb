# frozen_string_literal: true

# Install redis service.

return if skip_recipe
return chef_log('installed') if File.exist?('/usr/bin/redis-server')

redis_safe = node['rails_ubuntu']['redis_safe'].to_s =~ /^t/i

bash 'redis' do
  code <<-BASH
    #{bash_began}

    [ -e /etc/apt/sources.list.d/chris-lea-ubuntu-redis-server-* ] ||
      add-apt-repository -y ppa:chris-lea/redis-server

    apt-get update -qq
    apt-get install -y -qq redis-server redis-tools

    #{bash_ended}
  BASH
end

service 'redis-server' do
  action [ :enable, :start ]
end

unless redis_safe
  replace_or_add 'redis_unprotected' do
    path '/etc/redis/redis.conf'
    pattern '^protected-mode.*'
    line 'protected-mode no'
  end

  bash 'redis_unbound' do
    code <<~BASH
      #{bash_began('redis_unbound')}

      sed -i -e 's/^bind/# bind/' /etc/redis/redis.conf

      #{bash_ended('redis_unbound')}
    BASH
  end

  service 'redis-server' do
    action [ :restart ]
  end
end
