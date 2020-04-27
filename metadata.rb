# frozen_string_literal: true

name "rails_ubuntu"
maintainer "John Gorman"
maintainer_email "johngorman2@gmail.com"
license "MIT"
description "Provision Ubuntu for Rails deployment using Capistrano."
version "0.1.2"
chef_version ">= 14.0"
source_url "https://github.com/jgorman/rails_ubuntu"
issues_url "https://github.com/jgorman/rails_ubuntu/issues"
supports "ubuntu", "= 16.04"
supports "ubuntu", "= 18.04"

depends "line"
