# frozen_string_literal: true

# Install postgres or mysql.

return if skip_recipe

db_type = node["rails_ubuntu"]["db_type"]

case db_type
when "postgres"
  include_recipe "rails_ubuntu::postgres"
when "mysql"
  include_recipe "rails_ubuntu::mysql"
when "all"
  include_recipe "rails_ubuntu::postgres"
  include_recipe "rails_ubuntu::mysql"
else
  chef_log("skipped")
end
