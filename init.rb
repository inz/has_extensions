require 'has_extensions'

# Classes to be injected
Blackwhale::HasExtensions.base_classes.each do |klass|
  klass.send :include, Blackwhale::HasExtensions
end
