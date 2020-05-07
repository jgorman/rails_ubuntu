# frozen_string_literal: true

# Add bash aliases to the root and deploy users.

return if skip_recipe

bash_aliases  = node["rails_ubuntu"]["bash_aliases"]
deploy_user   = node["rails_ubuntu"]["deploy_user"]
deploy_group  = node["rails_ubuntu"]["deploy_group"] || deploy_user
deploy_home   = node["rails_ubuntu"]["deploy_home"] || "/home/#{deploy_user}"

chef_log("began")

file "/root/.bash_aliases" do
  action :create_if_missing
  content bash_aliases
end

file "#{deploy_home}/.bash_aliases" do
  user  deploy_user
  group deploy_group
  action :create_if_missing
  content bash_aliases
end

chef_log("ended")
