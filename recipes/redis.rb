# Install redis service.

# jj: xenial | bionic | focal inside of library.

bash "redis" do
  code <<-EOT
    exec >>~/chef.log 2>&1
    chmod a+w ~/chef.log
    echo -e "===\nLog redis began `date`\n"

    [ -e /etc/apt/sources.list.d/chris-lea-ubuntu-redis-server-xenial.list ] ||
      add-apt-repository -y ppa:chris-lea/redis-server

    apt-get update
    apt-get install -y -qq redis-server redis-tools

    echo -e "\nLog redis ended `date`"
  EOT
end

service 'redis-server' do
  action [ :enable, :start ]
end
