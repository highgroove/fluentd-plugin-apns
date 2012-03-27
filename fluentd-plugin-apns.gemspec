Gem::Specification.new do |gem|
  gem.authors       = ["vanstee"]
  gem.email         = ["vanstee@highgroove.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "fluentd-plugin-apns"
  gem.require_paths = ["lib"]
  gem.version       = "0.0.1"

  gem.add_dependency "fluentd", "~> 0.10.15"
  gem.add_dependency "apnserver", "~> 0.2.2"

  gem.add_development_dependency "rake"
  gem.add_development_dependency "mocha"
  gem.add_development_dependency "pry"
end
