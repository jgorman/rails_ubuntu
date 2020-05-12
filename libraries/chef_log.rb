# frozen_string_literal: true

#####
#
# Log to ~deploy_user/chef.log.
#
#####

module ChefLog
  def bash_began(recipe = @recipe_name)
    set_deploy_home()
    <<~BASH
      exec >>~/chef.log 2>&1
      chmod a+w ~/chef.log 2>/dev/null
      echo -e "\\n<<< Recipe #{recipe} began `date`\\n"
    BASH
  end

  def bash_ended(recipe = @recipe_name)
    <<~BASH
      echo -e "\\n>>> Recipe #{recipe} ended `date`"
    BASH
  end

  def chef_log(msg, recipe = @recipe_name)
    set_deploy_home()
    bash msg do
      code <<~BASH
        exec >>~/chef.log 2>&1
        chmod a+w ~/chef.log 2>/dev/null
        echo -e "\\n=== Recipe #{recipe} #{msg} `date`"
      BASH
    end
  end

  def skip_recipe
    set_deploy_home()
    skip_recipes = get_attr('skip_recipes') || ''
    if skip_recipes.include?(@recipe_name)
      chef_log('skipped')
      true
    else
      false
    end
  end

  def get_attr(attr)
    node[@cookbook_name] && node[@cookbook_name][attr]
  end

  def set_deploy_home
    if (deploy_home = get_attr('deploy_home'))
      ENV['HOME'] = deploy_home
    elsif ENV['HOME'] == '/root'

      # There is a Chef Workstation 0.18.3 bug on Ubuntu 20.04.
      # $HOME is set to /root instead of /home/vagrant.
      deploy_user = get_attr('deploy_user')
      if deploy_user != 'root'
        ENV['HOME'] = "/home/#{deploy_user}"
      end

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
