module Trainyard
  module ActsAsOrganizer
    def self.included(base)
      base.extend(MacroMethods)
    end
  
    module MacroMethods
      def acts_as_organizer(*args)
        class_eval do
          def membered_organizations
            @membered_organizations ||= self.membered(Organization)
          end
  
          def moderated_organizations
            @moderated_organizations ||= self.moderated(Organization)
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Trainyard::ActsAsOrganizer) if defined?(ActiveRecord::Base)