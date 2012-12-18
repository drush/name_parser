$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "name_parser/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "name_parser"
  s.version     = NameParser::VERSION
  s.authors     = ["Darren Rush"]
  s.email       = ["dlrush@gmail.com"]
  s.homepage    = "https://github.com/drush/name_parser"
  s.summary     = "Parse a name already"
  s.description = "First, last, middle, whatever"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  #s.add_dependency "rails", "~> 3.2.9"

  #s.add_development_dependency "sqlite3"
end
