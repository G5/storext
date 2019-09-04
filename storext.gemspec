$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "storext/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "storext"
  s.version     = Storext::VERSION
  s.authors     = ["G5", "Ramon Tayag", "Marc Rendl Ignacio"]
  s.email       = ["lateam@getg5.com", "ramon.tayag@gmail.com", "marcrendlignacio@gmail.com"]
  s.homepage    = "http://github.com/g5/storext"
  s.summary     = "Extends ActiveRecord::Store.store_accessor"
  s.description = "Extends ActiveRecord::Store.store_accessor"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "virtus"
  s.add_dependency "activerecord", [">= 4.0", "< 6.1"]

  s.add_development_dependency "pg"
  s.add_development_dependency "rspec"
  s.add_development_dependency "database_cleaner"
  s.add_development_dependency "rails"
end
