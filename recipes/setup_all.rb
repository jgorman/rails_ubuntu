# Set up rails on ubuntu.

include_recipe '::bash_aliases'
include_recipe '::apt_upgrade'
include_recipe '::apt_install'
include_recipe '::ripgrep_install'
include_recipe '::ruby_install'
include_recipe '::nodejs_install'
include_recipe '::redis_install'
include_recipe '::nginx_install'
include_recipe '::db_install'
