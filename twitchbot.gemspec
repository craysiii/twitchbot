lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'twitchbot/version'

Gem::Specification.new do |spec|
  spec.name          = 'twitchbot'
  spec.version       = Twitchbot::VERSION
  spec.authors       = ['Charles Ray Shisler III']
  spec.email         = ['charles@cray.io']

  spec.summary       = 'A library for creating Twitch.tv chat bots'
  spec.homepage      = 'https://github.com/craysiii/twitchbot'
  spec.license       = 'MIT'

  spec.files         = Dir['bin/*'] +
                       Dir['lib/**/*.rb'] +
                       %w[LICENSE.txt README.md]

  spec.bindir        = 'bin'

  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'

  spec.add_runtime_dependency 'faye-websocket', '~> 0.10.7'
end
