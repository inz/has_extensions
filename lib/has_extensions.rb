module Blackwhale::HasExtensions
  # Default base classes to be extended.
  mattr_accessor :base_classes
  @@base_classes = [ 
    ActiveRecord::Base, 
    ActiveRecord::Observer, 
    ActionController::Base 
  ]
  
  
  module ClassMethods
    def has_extensions
      extension_modules = []

      directory_basename = "%s_extensions" % self.to_s.underscore
      extensions_path = File.join(
        Rails.root, 
        "**", 
        directory_basename,
        '*.rb'
      )
      
      Dir[extensions_path].each do |user_extension|
        extension_modules << [directory_basename, File.basename(user_extension)[0..-4]].
        map(&:camelize).
        join('::').
        constantize
      end

      # Include found modules in the User model.
      extension_modules.uniq.each do |m|
        if defined?(m::InstanceMethods) && !self.included_modules.include?(m::InstanceMethods)
          self.send :include, m::InstanceMethods
          Rails.logger.debug "Extending #{self.inspect} with #{m::InstanceMethods.inspect}"
        end

        if defined?(m::ClassMethods) && !self.extended_by.include?(m::ClassMethods)
          self.send :extend, m::ClassMethods
          Rails.logger.debug "Extending #{self.inspect} with #{m::ClassMethods.inspect}"
        end
      end
    end
  end
  
  def self.included(receiver)
    receiver.extend         ClassMethods
  end
end
