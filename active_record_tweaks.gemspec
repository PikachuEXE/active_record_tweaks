# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

author_name = "PikachuEXE"
gem_name = "active_record_tweaks"

require "#{gem_name}/version"

Gem::Specification.new do |s|
  s.platform      = Gem::Platform::RUBY
  s.name          = gem_name
  s.version       = ActiveRecordTweaks::VERSION
  s.summary       = "Some Tweaks for ActiveRecord"
  s.description   = "ActiveRecord is great, but could be better. Here are some tweaks for it."

  s.license       = "MIT"

  s.authors       = [author_name]
  s.email         = ["pikachuexe@gmail.com"]
  s.homepage      = "http://github.com/#{author_name}/#{gem_name}"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "activerecord", ">= 3.2.0", "< 5.0.0"
  s.add_dependency "activesupport", ">= 3.2.0", "< 5.0.0"

  s.add_development_dependency "bundler", ">= 1.0.0"
  s.add_development_dependency "rake", ">= 0.9.2"
  s.add_development_dependency "appraisal", ">= 0.5.2"
  s.add_development_dependency "rspec", "~> 2.6"
  s.add_development_dependency "sqlite3", ">= 1.3"
  s.add_development_dependency "database_cleaner", ">= 1.0"
  s.add_development_dependency "coveralls", ">= 0.7"
  s.add_development_dependency "gem-release", ">= 0.7"

  s.required_rubygems_version = ">= 1.4.0"
end
