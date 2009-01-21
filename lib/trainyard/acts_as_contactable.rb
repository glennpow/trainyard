module Trainyard
  module ActsAsContactable
    def self.included(base)
      base.extend(MacroMethods)
    end
  
    module MacroMethods
      def acts_as_contactable(*args)
        name = args.first || :contact
        
        class_eval do
          has_one name, :as => :resource, :class_name => 'Contact', :dependent => :destroy

          has_accessible name

          attr_accessible name
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Trainyard::ActsAsContactable) if defined?(ActiveRecord::Base)