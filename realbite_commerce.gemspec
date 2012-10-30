require 'rubygems'
require 'rake'
require './lib/realbite/commerce/version'
Gem::Specification.new do |spec|

spec.name    = 'realbite_commerce'
spec.version = Commerce::VERSION
spec.author  = "Clive Andrews"
spec.email   = "pacman@realitybites.nl"

spec.platform = Gem::Platform::RUBY
spec.summary = 'some classes for manipulating money,price,tax..'
spec.require_path = 'lib'

spec.files = FileList['lib/**/*.rb'].to_a
spec.extra_rdoc_files = ['README','LICENCE']

spec.add_dependency('bigdecimal_places')

end
