
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rock_books/version'

Gem::Specification.new do |spec|
  spec.name          = 'rock_books'
  spec.version       = RockBooks::VERSION
  spec.authors       = ['Keith Bennett']
  spec.email         = ['keithrbennett@gmail.com']

  spec.summary       = %q{Very basic accounting package.}
  spec.description   = %q{Extremely primitive accounting software.}
  spec.homepage      = 'http://example.com'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = ': Set to 'http://mygemserver.com''
  # else
  #   raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'amazing_print', '>= 1.4.0', '< 2'
  spec.add_dependency 'os', '> 1.0.0', '< 2'
  spec.add_dependency 'pry', '>= 0.14.2', '< 2'
  spec.add_dependency 'prawn', '>= 2.4.0', '< 3'
  spec.add_dependency 'tty-progressbar', '0.18.2', '< 2'

  spec.add_development_dependency 'bundler', '>= 2.2.33', '< 3'
  spec.add_development_dependency 'rake', '> 13.0.6', '< 14'
  spec.add_development_dependency 'rspec', '> 3.12.0', '< 4'
end
