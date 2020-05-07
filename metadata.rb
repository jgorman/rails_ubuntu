# frozen_string_literal: true

name "rails_ubuntu"
maintainer "John Gorman"
maintainer_email "johngorman2@gmail.com"
license "MIT"
description "Provision Ubuntu for Rails and Node deployment using Capistrano."
version "0.2.0"
chef_version ">= 14.0"
source_url "https://github.com/jgorman/rails_ubuntu"
issues_url "https://github.com/jgorman/rails_ubuntu/issues"
supports "ubuntu", "= 16.04"
supports "ubuntu", "= 18.04"

depends "line"
