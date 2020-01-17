$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "deal_maker/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "deal_maker"
  s.version     = DealMaker::VERSION
  s.authors     = ["Yottolabs"]
  s.email       = ["yottolabs@gmail.com"]
  s.homepage    = "http://yottolabs.com"
  s.summary     = "Summary of DealMaker."
  s.description = "Description of DealMaker."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.13"
  # s.add_dependency "jquery-rails"

  s.add_development_dependency "pg"
end
