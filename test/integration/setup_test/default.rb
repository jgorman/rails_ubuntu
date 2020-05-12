# frozen_string_literal: true

# InSpec test for recipe rails_ubuntu::setup_test

# The InSpec reference, with examples and extensive documentation, can be
# found at https://www.inspec.io/docs/reference/resources/

describe file('/etc/security/limits.conf') do
  it { should exist }
  its('content') { should match(/^[*] soft nofile [1-9][0-9]*$/) }
  its('content') { should match(/^[*] hard nofile [1-9][0-9]*$/) }
  its('content') { should match(/^root soft nofile [1-9][0-9]*$/) }
  its('content') { should match(/^root hard nofile [1-9][0-9]*$/) }
end

describe file('/etc/pam.d/common-session') do
  it { should exist }
  its('content') { should match(/^session required pam_limits.so$/) }
end

describe file('/etc/sysctl.conf') do
  it { should exist }
  its('content') { should match(/^fs.inotify.max_user_watches=[1-9][0-9]*$/) }
end

describe file('/root/.bash_aliases') do
  it { should exist }
  its('content') { should match(/^alias/) }
end

describe directory('/home/vagrant/activity-timer') do
  it { should exist }
end

describe command('rg --version') do
  its('exit_status') { should cmp 0 }
  its('stdout') { should match(/ripgrep/) }
end

describe command('/home/vagrant/.rbenv/shims/ruby --version') do
  its('exit_status') { should cmp 0 }
  its('stdout') { should match(/^ruby [2-9]\.[0-9]/) }
end

describe command('/home/vagrant/.rbenv/shims/gem list') do
  its('exit_status') { should cmp 0 }
  its('stdout') { should match(/^bundler/) }
end

describe command('node --version') do
  its('exit_status') { should cmp 0 }
  its('stdout') { should match(/^v[1-9][0-9]/) }
end

describe service('redis-server') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end
describe port(6379) do
  it { should be_listening }
end

describe service('nginx') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end
describe port(80) do
  it { should be_listening }
end

describe command('passenger-status') do
  its('exit_status') { should cmp 0 }
  its('stdout') { should match(/Phusion_Passenger/) }
end

describe service('postgresql') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end
describe port(5432) do
  it { should be_listening }
end

describe service('mysql') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end
describe port(3306) do
  it { should be_listening }
end

describe service('proxysql') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end
describe port(6032) do
  it { should be_listening }
end
describe port(6033) do
  it { should be_listening }
end
