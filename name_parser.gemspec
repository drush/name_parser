$LOAD_PATH.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'name_parser/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'name_parser'
  s.version     = NameParser::VERSION
  s.authors     = ['Darren Rush']
  s.email       = ['dlrush@gmail.com']
  s.homepage    = 'https://github.com/drush/name_parser'
  s.summary     = 'Parse a name already'
  s.description = 'First, last, middle, whatever'

  s.files = Dir['{app,config,db,lib}/**/*'] + ['MIT-LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['test/**/*']

  s.add_development_dependency 'rake', '>= 12.3.1'
  s.add_development_dependency 'minitest', '>= 5.8'
  s.add_development_dependency 'minitest-reporters', '>= 1.1'
end
