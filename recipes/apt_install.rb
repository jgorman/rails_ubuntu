# Install basic packages.

return if skip_recipe

apt_install = node['rails_ubuntu']['apt_install']
open_files  = node['rails_ubuntu']['open_files'].to_i

bash 'apt_install' do
  code <<-EOT
    #{bash_began}

    apt-get update -qq
    apt-get install -y -qq #{apt_install}

    #{bash_ended}
  EOT
end

if open_files > 0

  limits_path = '/etc/security/limits.conf'

  replace_or_add 'limits.conf' do
    path limits_path
    pattern '[*].*soft.*nofile'
    line "* soft nofile #{open_files}"
  end

  replace_or_add 'limits.conf' do
    path limits_path
    pattern '[*].*hard.*nofile'
    line "* hard nofile #{open_files}"
  end

  replace_or_add 'limits.conf' do
    path limits_path
    pattern 'root.*soft.*nofile'
    line "root soft nofile #{open_files}"
  end

  replace_or_add 'limits.conf' do
    path limits_path
    pattern 'root.*hard.*nofile'
    line "root hard nofile #{open_files}"
  end

  replace_or_add 'pam.d' do
    path '/etc/pam.d/common-session'
    pattern 'session.*required.*pam_limits.so'
    line 'session required pam_limits.so'
  end

end
