#####
#
# Log to ~deploy_user/chef.log.
#
#####

module ::RailsUbuntuLogger

  def bash_began(recipe = @recipe_name)
    <<-EOT
      exec >>~/chef.log 2>&1
      chmod a+w ~/chef.log 2>/dev/null
      echo -e "===\\nRecipe #{recipe} began `date`\\n"
    EOT
  end

  def bash_ended(recipe = @recipe_name)
    <<-EOT
      echo -e "\\nRecipe #{recipe} ended `date`"
    EOT
  end

  def log_msg(msg)
    bash "log_msg" do
      code <<-EOT
        exec >>~/chef.log 2>&1
        chmod a+w ~/chef.log 2>/dev/null
        echo -e "===\\nRecipe #{recipe_name} #{msg} `date`"
      EOT
    end
  end

  def skip_recipe
    skip_recipes = node[@cookbook_name] && node[@cookbook_name]['skip_recipes']
    skip_recipes ||= ''
    if skip_recipes.include?(@recipe_name)
      log_msg('skipped')
      true
    else
      false
    end
  end

end

class Chef::Recipe
  include ::RailsUbuntuLogger
end

class Chef::Resource::Bash
  include ::RailsUbuntuLogger
end

class Chef::Resource::File
  include ::RailsUbuntuLogger
end
