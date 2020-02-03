# Install postgres or mysql.

return if skip_recipe

db_type = node['rails_ubuntu']['db_type']

case db_type
when 'postgres'
  include_recipe '::postgres'
when 'mysql'
  include_recipe '::mysql'
when 'all'
  include_recipe '::postgres'
  include_recipe '::mysql'
else
  chef_log('skipped')
end
