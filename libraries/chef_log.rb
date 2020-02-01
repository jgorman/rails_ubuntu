#####
#
# Log to ~deploy_user/chef.log.
#
#####

module ChefLog
  def bash_began(recipe = @recipe_name)
    <<-EOT
      exec >>~/chef.log 2>&1
      chmod a+w ~/chef.log 2>/dev/null
      echo -e "\\n<<< Recipe #{recipe} began `date`\\n"
    EOT
  end

  def bash_ended(recipe = @recipe_name)
    <<-EOT
      echo -e "\\n>>> Recipe #{recipe} ended `date`"
    EOT
  end

  def chef_log(msg, recipe = @recipe_name)
    bash msg do
      code <<-EOT
        exec >>~/chef.log 2>&1
        chmod a+w ~/chef.log 2>/dev/null
        echo -e "\\n=== Recipe #{recipe} #{msg} `date`"
      EOT
    end
  end

  def skip_recipe
    skip_recipes = node[@cookbook_name] && node[@cookbook_name]['skip_recipes']
    skip_recipes ||= ''
    if skip_recipes.include?(@recipe_name)
      chef_log('skipped')
      true
    else
      false
    end
  end
end

class Chef::Recipe
  include ChefLog
end

class Chef::Resource::Bash
  include ChefLog
end

class Chef::Resource::File
  include ChefLog
end
