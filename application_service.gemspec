# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: application_service 0.4.1 ruby lib

Gem::Specification.new do |s|
  s.name = "application_service".freeze
  s.version = "0.4.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Nathan Woodhull".freeze]
  s.date = "2022-03-02"
  s.description = "A service layer scaffold for rails apps extracted from Agra".freeze
  s.email = "woodhull@gmail.com".freeze
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    ".document",
    ".github/workflows/ci.yml",
    ".rspec",
    ".rubocop.yml",
    ".ruby-gemset",
    ".ruby-version",
    "Gemfile",
    "LICENSE.txt",
    "README.md",
    "Rakefile",
    "VERSION",
    "application_service.gemspec",
    "lib/application_service.rb",
    "spec/application_service_spec.rb",
    "spec/spec_helper.rb"
  ]
  s.homepage = "http://github.com/woodhull/application_service".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.2.32".freeze
  s.summary = "Service Layer Scaffold".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<activesupport>.freeze, [">= 5.0.0.1"])
    s.add_development_dependency(%q<rspec>.freeze, ["~> 3.5"])
    s.add_development_dependency(%q<rubocop>.freeze, [">= 0"])
    s.add_development_dependency(%q<jeweler>.freeze, ["~> 2.2", ">= 2.2.1"])
  else
    s.add_dependency(%q<activesupport>.freeze, [">= 5.0.0.1"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.5"])
    s.add_dependency(%q<rubocop>.freeze, [">= 0"])
    s.add_dependency(%q<jeweler>.freeze, ["~> 2.2", ">= 2.2.1"])
  end
end

