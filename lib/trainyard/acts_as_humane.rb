module Trainyard
  module ActsAsHumane
    def self.included(base)
      base.extend(MacroMethods)
    end
  
    module MacroMethods
      def acts_as_humane(*args)
        options = args.extract_options!
        
        class_eval do
          validates_acceptance_of :verified_human, options.reverse_merge(:accept => true)
        end
          
        define_method :should_verify_human do
          case options[:unless]
          when Symbol, String
            return false if self.try(options[:unless])
          when Proc
            return false if Proc.call(self)
          end
          
          case options[:if]
          when Symbol, String
            return false if !self.try(options[:if])
          when Proc
            return false if !Proc.call(self)
          end
          
          return true
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Trainyard::ActsAsHumane) if defined?(ActiveRecord::Base)