# frozen_string_literal: true

#####
#
# Log to ~deploy_user/chef.log.
#
#####

module ChefLog
  def bash_began(recipe = @recipe_name)
    deploy_user = get_attr("deploy_user")
    <<~BASH
      exec >>~#{deploy_user}/chef.log 2>&1
      chmod a+w ~#{deploy_user}/chef.log 2>/dev/null
      echo -e "\\n<<< Recipe #{recipe} began `date`\\n"
    BASH
  end

  def bash_ended(recipe = @recipe_name)
    <<~BASH
      echo -e "\\n>>> Recipe #{recipe} ended `date`"
    BASH
  end

  def chef_log(msg, recipe = @recipe_name)
    deploy_user = get_attr("deploy_user")
    bash msg do
      code <<~BASH
        exec >>~#{deploy_user}/chef.log 2>&1
        chmod a+w ~#{deploy_user}/chef.log 2>/dev/null
        echo -e "\\n=== Recipe #{recipe} #{msg} `date`"
      BASH
    end
  end

  def skip_recipe
    skip_recipes = get_attr("skip_recipes")
    if skip_recipes.include?(@recipe_name)
      chef_log("skipped")
      true
    else
      false
    end
  end

  def get_attr(attr)
    (node[@cookbook_name] && node[@cookbook_name][attr]) || ""
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
