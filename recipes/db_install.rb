# Install database.

db_type = get(:db_type) || 'postgres'

case db_type
when 'postgres'
  include_recipe '::postgres_install'
when 'mysql'
  include_recipe '::mysql_install'
else
  raise "Unknown db_type '#{db_type}'"
end
