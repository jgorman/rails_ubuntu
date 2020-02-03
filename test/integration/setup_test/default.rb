# InSpec test for recipe rails_ubuntu::setup_test

# The InSpec reference, with examples and extensive documentation, can be
# found at https://www.inspec.io/docs/reference/resources/

describe file('/root/.bash_aliases') do
  it { should exist }
  its('content') { should match(/^alias/) }
end

describe service('nginx') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end
describe port(80) do
  it { should be_listening }
end

describe service('redis-server') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end
describe port(6379) do
  it { should be_listening }
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

describe command('/home/vagrant/.rbenv/shims/ruby --version') do
  its('exit_status') { should cmp 0 }
  its('stdout') { should match /^ruby 2\.6\.5/ }
end

describe command('node --version') do
  its('exit_status') { should cmp 0 }
  its('stdout') { should match /^v12/ }
end

describe command('rg') do
  it { should exist }
end
