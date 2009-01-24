module Trainyard
  module ActsAsResource
    def self.included(base)
      base.extend(MacroMethods)
    end
  
    module MacroMethods
      def acts_as_resource(*args)
        options = args.extract_options!
        
        unless options[:group] == false
          group_options = options[:group] || {}
        
          class_eval do
            if group_options[:through]
              has_one :group, group_options
            else
              belongs_to :group, group_options.reverse_merge(:class_name => 'Group')
            end

            has_accessible :group if group_options[:dependent] == :destroy
          end
        
          define_method :moderators do
            @moderators ||= self.group.moderators
          end
        end

        permissions_options = options[:permissions] || {}
        
        class_eval do
          has_many :permissions, permissions_options.reverse_merge(:class_name => 'Permission', :as => :resource, :dependent => :destroy)
          
          after_create :create_default_permissions
          
          def create_default_permissions
            Permission.create(:group_id => self.group_id, :action_id => Action.edit.id, :role_id => Role.editor.id, :resource => self)
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Trainyard::ActsAsResource) if defined?(ActiveRecord::Base)