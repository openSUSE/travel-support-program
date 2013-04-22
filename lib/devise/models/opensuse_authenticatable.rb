# Empty, but Devise seems to require a model
module Devise
  module Models
    module OpensuseAuthenticatable
      def self.included(base)
        base.extend ClassMethods
      end   
          
      module ClassMethods
      end
          
      module InstanceMethods
        def valid_for_authentication?
        end
      end
    end
  end   
end   
