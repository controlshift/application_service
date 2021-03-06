# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: application_service 0.4.0 ruby lib

Gem::Specification.new do |s|
  s.name = "application_service".freeze
  s.version = "0.4.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Nathan Woodhull".freeze]
  s.date = "2021-05-20"
  s.description = "A service layer scaffold for rails apps extracted from Agra".freeze
  s.email = "woodhull@gmail.com".freeze
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    ".rspec",
    ".rubocop.yml",
    ".ruby-gemset",
    ".ruby-version",
    ".travis.yml",
    "Gemfile",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "application_service.gemspec",
    "lib/application_service.rb",
    "spec/application_service_spec.rb",
    "spec/spec_helper.rb"
  ]
  s.homepage = "http://github.com/woodhull/application_service".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.1.6".freeze
  s.summary = "Service Layer Scaffold".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<activesupport>.freeze, [">= 5.0.0.1", "< 7.0"])
    s.add_development_dependency(%q<rspec>.freeze, ["~> 3.5"])
    s.add_development_dependency(%q<rubocop>.freeze, ["~> 1.15"])
    s.add_development_dependency(%q<jeweler>.freeze, ["~> 2.2", ">= 2.2.1"])
  else
    s.add_dependency(%q<activesupport>.freeze, [">= 5.0.0.1", "< 7.0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.5"])
    s.add_dependency(%q<rubocop>.freeze, ["~> 1.15"])
    s.add_dependency(%q<jeweler>.freeze, ["~> 2.2", ">= 2.2.1"])
  end
end

