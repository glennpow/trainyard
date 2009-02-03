module Trainyard
  module ActsAsOrganizable
    def self.included(base)
      base.extend(MacroMethods)
    end
  
    module MacroMethods
      def acts_as_organizable(*args)
        options = args.extract_options!
        organization_name = args.first || :organization
      
        class_eval do
          belongs_to organization_name, options.reverse_merge(:class_name => 'Organization')
          
          validates_presence_of organization_name

          has_accessible organization_name
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Trainyard::ActsAsOrganizable) if defined?(ActiveRecord::Base)