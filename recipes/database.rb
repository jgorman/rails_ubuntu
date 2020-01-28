# Install postgres or mysql.

return if skip_recipe

case get(:db_type)
when 'postgres'
  include_recipe '::postgres'
when 'mysql'
  include_recipe '::mysql'
when 'both'
  include_recipe '::postgres'
  include_recipe '::mysql'
else
  log_msg('skipped')
end
