# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'monotony/version'

Gem::Specification.new do |spec|
  spec.name          = "monotony"
  spec.version       = Monotony::VERSION
  spec.authors       = ["James Denness"]
  spec.email         = ["james@recordlive.net"]

  spec.summary       = %q{Monopoly game simulator}
  spec.description   = %q{A simple engine for simulating games of Monopony.}
  spec.homepage      = "http://recordlive.audio"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'deep_dive'
  spec.add_dependency 'colorize'

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"
end
