#####
#
# This adds the get and set attribute config helpers to Recipe, Bash, File.
# get/set are shorter, and do not hardcode the cookbook name anywhere.
#
#   get(:deploy_user) ==>
#     node[@cookbook_name][:deploy_user]
#
#   set(:deploy_user, 'vagrant') ==>
#     node.default[@cookbook_name][:deploy_user] = 'vagrant'
#
# Use them in any recipe, bash script or file.
#
#   file "/home/#{get(:deploy_user)}/.bash_aliases" do
#     user get(:deploy_user)
#     group get(:deploy_group)
#     content aliases
#   end
#
# For templates, add an inline helper.
#
#   template "/etc/nginx/sites-enabled/#{get(:app_name)}" do
#     helper(:get) {|key| node[@cookbook_name][key] }
#     source "nginx_site.erb"
#   end
#
# Use get inside of the erb template.
#
#   root /home/<%= get(:deploy_user) %>/<%= get(:app_name) %>/current/public;
#
# Manually add "def get" to other resources such as the line cookbook.
#
#   replace_or_add 'mod-http-passenger.conf' do
#     def get(key); node[@cookbook_name][key] end
#     path '/etc/nginx/conf.d/mod-http-passenger.conf'
#     pattern '.*passenger_ruby.*'
#     line "passenger_ruby /home/#{get(:deploy_user)}/.rbenv/shims/ruby;"
#   end
#
#####

module ::RailsUbuntuHelpers

  def get(key)
    node[@cookbook_name][key]
  end

  def set(key, value)
    node.default[@cookbook_name][key] = value
  end

end

class Chef::Recipe
  include ::RailsUbuntuHelpers
end

class Chef::Resource::Bash
  include ::RailsUbuntuHelpers

end

class Chef::Resource::File
  include ::RailsUbuntuHelpers
end
