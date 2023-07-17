# -*- encoding: utf-8 -*-
# rubocop:disable all
$LOAD_PATH.push File.expand_path("../lib", __FILE__)

author_name = "PikachuEXE"
gem_name = "active_record_tweaks"

require "#{gem_name}/version"

Gem::Specification.new do |s|
  s.platform      = Gem::Platform::RUBY
  s.name          = gem_name
  s.version       = ActiveRecordTweaks::VERSION
  s.summary       = "Some Tweaks for ActiveRecord"
  s.description   = <<-DOC
    ActiveRecord is great, but could be better. Here are some tweaks for it.
  DOC

  s.license       = "MIT"

  s.authors       = [author_name]
  s.email         = ["pikachuexe@gmail.com"]
  s.homepage      = "http://github.com/#{author_name}/#{gem_name}"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "activerecord", ">= 6.0.0", "< 8.0.0"

  s.add_development_dependency "bundler", ">= 1.0.0"
  s.add_development_dependency "rake", ">= 10.0", "<= 14.0"
  s.add_development_dependency "appraisal", "~> 2.0", ">= 2.5.0"
  s.add_development_dependency "rspec", "~> 3.0"
  s.add_development_dependency "rspec-its", "~> 1.0"
  s.add_development_dependency "sqlite3", ">= 1.3"
  s.add_development_dependency "database_cleaner", ">= 1.0"
  s.add_development_dependency "simplecov", ">= 0.21"
  s.add_development_dependency "simplecov-lcov", ">= 0.8"
  s.add_development_dependency "gem-release", ">= 0.7"
  s.add_development_dependency "timecop", ">= 0.7.1"

  s.required_ruby_version = ">= 2.7.0"

  s.required_rubygems_version = ">= 1.4.0"
end
