module Trainyard
  module ActsAsContactable
    def self.included(base)
      base.extend(MacroMethods)
    end
  
    module MacroMethods
      def acts_as_contactable(*args)
        options = args.extract_options!
        attribute_name = args.first || :contact
        
        class_eval do
          has_one attribute_name, options.reverse_merge(:as => :resource, :class_name => 'Contact', :dependent => :destroy)

          has_accessible attribute_name

          attr_accessible attribute_name
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Trainyard::ActsAsContactable) if defined?(ActiveRecord::Base)