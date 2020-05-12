# frozen_string_literal: true

# Policyfile.rb - Describe how you want Chef Infra Client to build your system.
#
# For more information on the Policyfile feature, visit
# https://docs.chef.io/policyfile.html

# A name that describes what the system you're building with Chef does.
name 'rails_ubuntu'

# Where to find external cookbooks:
default_source :supermarket

# run_list: chef-client will run these recipes in the order specified.
run_list 'rails_ubuntu::default'

named_run_list 'kitchen_test', 'rails_ubuntu::setup_test'

# Specify a custom source for a single cookbook:
cookbook 'rails_ubuntu', path: '.'
cookbook 'line', '~> 2.0.1', :supermarket
