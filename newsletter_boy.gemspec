Gem::Specification.new do |s|
  s.name        = "newsletter_boy"
  s.version     = "1.0.0"
  s.author      = "Digineo GmbH"
  s.email       = "kontakt@digineo.de"
  s.homepage    = "http://digineo.de"
  s.summary     = "NewsletterBoy Api"
  s.description = "NewsletterBoy Api"
  
  s.files        = Dir["{lib,test}/**/*"] + Dir["[A-Z]*"] + ["init.rb"]
  s.require_path = "lib"
end
