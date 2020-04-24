# Ubuntu tuning requires a reboot in order to be effective.

return if skip_recipe

nofile  = node['rails_ubuntu']['nofile'].to_i
inotify = node['rails_ubuntu']['inotify'].to_i

# https://posidev.com/blog/2009/06/04/set-ulimit-parameters-on-ubuntu/
if nofile > 0
  limits_conf = '/etc/security/limits.conf'

  replace_or_add limits_conf do
    path limits_conf
    pattern '[*].*soft.*nofile'
    line "* soft nofile #{nofile}"
  end

  replace_or_add limits_conf do
    path limits_conf
    pattern '[*].*hard.*nofile'
    line "* hard nofile #{nofile}"
  end

  replace_or_add limits_conf do
    path limits_conf
    pattern 'root.*soft.*nofile'
    line "root soft nofile #{nofile}"
  end

  replace_or_add limits_conf do
    path limits_conf
    pattern 'root.*hard.*nofile'
    line "root hard nofile #{nofile}"
  end

  replace_or_add 'pam.d' do
    path '/etc/pam.d/common-session'
    pattern 'session.*required.*pam_limits.so'
    line 'session required pam_limits.so'
  end
end

# https://github.com/guard/listen/wiki/Increasing-the-amount-of-inotify-watchers
if inotify > 0
  sysctl_conf = '/etc/sysctl.conf'

  replace_or_add sysctl_conf do
    path sysctl_conf
    pattern 'fs.inotify.max_user_watches'
    line "fs.inotify.max_user_watches=#{inotify}"
  end

  bash 'tune inotify' do
    code <<-EOT
      #{bash_began}

      sysctl -p

      #{bash_ended}
    EOT
  end
end
