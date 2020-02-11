# Install basic packages.

return if skip_recipe

apt_install = node['rails_ubuntu']['apt_install']

bash 'apt_install' do
  code <<-EOT
    #{bash_began}

    apt-get update -qq
    apt-get install -y -qq #{apt_install}

    #{bash_ended}
  EOT
end
