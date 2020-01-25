# Install postgres or mysql.

return if skip_recipe

case get(:db_type)
when 'postgres'
  include_recipe '::postgres'
when 'mysql'
  raise "Recipe to install mysql not written yet."
  include_recipe '::mysql'
else
  log_msg('skipped')
end
