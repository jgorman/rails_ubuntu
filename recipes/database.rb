# Install postgres or mysql.

db_type = get(:db_type) || 'postgres'

case db_type
when 'postgres'
  include_recipe '::postgres'
when 'mysql'
  raise "Recipe to install mysql not written yet."
  include_recipe '::mysql'
else
  raise "Unknown db_type '#{db_type}'"
end
